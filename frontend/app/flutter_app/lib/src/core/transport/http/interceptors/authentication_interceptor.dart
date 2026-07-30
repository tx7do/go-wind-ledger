import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/src/core/constants/index.dart' show AppRoutePath;
import 'package:flutter_app/src/core/services/base_service.dart'
    show BaseService;
import 'package:flutter_app/src/core/utilities/jwt_utils.dart' show JwtUtils;
import 'package:flutter_app/src/core/utilities/logger.dart' show fatal;

/// 认证服务接口，定义了获取和刷新令牌的方法
abstract class AuthService extends BaseService {
  /// 获取当前访问令牌
  String? getAccessToken();

  /// 获取刷新令牌
  String? getRefreshToken();

  /// 刷新访问令牌
  /// 返回新的访问令牌，失败时返回null
  Future<String?> refreshToken();

  /// 认证失败处理
  authenticationFailed();
}

/// 认证拦截器
///
/// 职责：
/// 1. onRequest：为业务请求注入 Bearer access token；若 token 即将过期则先
///    主动刷新，实现无感续期。login 与 refresh-token 端点跳过注入与刷新。
/// 2. onError：捕获 401，尝试用 refresh token 续期并重试原请求；刷新失败则
///    清除认证状态并跳转登录页。
class AuthenticationInterceptor extends Interceptor {
  final AuthService _authService;
  final bool _autoRefreshToken;

  /// 并发刷新去重锁。
  ///
  /// 为 null 表示当前无刷新进行中；非 null 表示有一个进行中的刷新，其
  /// [Completer.future] 完成时携带新 access token（或 null 表示失败）。
  /// 并发的 401/即将过期检查会 await 同一个 future，避免重复触发刷新。
  Completer<String?>? _refreshFuture;

  /// 创建认证拦截器实例
  /// [authService] - 认证服务实现
  /// [autoRefreshToken] - 是否自动刷新令牌，默认为true
  AuthenticationInterceptor({
    required AuthService authService,
    bool autoRefreshToken = true,
  }) : _authService = authService,
       _autoRefreshToken = autoRefreshToken;

  /// 判断请求路径是否应跳过 token 注入与刷新。
  ///
  /// login 与 refresh-token 端点本身不需要（也不应）携带 access token：
  /// - login 是获取初始令牌的入口；
  /// - refresh-token 端点已免认证，携带即将过期的 access token 反而可能
  ///   导致服务端误判，且会触发无意义的递归刷新。
  bool _shouldSkipToken(String path) {
    return path == AppRoutePath.login || _isRefreshTokenPath(path);
  }

  /// 识别 refresh-token 端点路径（后缀匹配，兼容 baseUrl 拼接前后形态）。
  bool _isRefreshTokenPath(String path) {
    return path.endsWith('/refresh-token');
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkipToken(options.path)) {
      return handler.next(options);
    }

    var token = _authService.getAccessToken();

    // 主动提前刷新：若 access token 即将过期（或已过期），先尝试用 refresh
    // token 续期，再用新 token 发起请求。这样业务请求到达服务端时 token 仍
    // 有效，避免触发 401 的被动刷新往返，实现无感续期。
    if (token != null && token.isNotEmpty && JwtUtils.willExpireSoon(token)) {
      final refreshed = await _refreshToken();
      if (refreshed != null) {
        token = _authService.getAccessToken();
      } else {
        // 刷新失败：refresh token 无效或过期，清除认证状态并跳转登录页，
        // 随后放行无 token 的请求（将由服务端 401 或路由守卫兜底）。
        await _authService.authenticationFailed();
        return handler.next(options);
      }
    }

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = _makeBearerToken(accessToken: token);
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response == null) {
      return handler.next(err);
    }

    // 如果不需要自动刷新令牌或不是401错误，则直接传递错误
    if (!_autoRefreshToken || err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // refresh-token 端点自身返回 401 说明 refresh token 无效/过期，
    // 不再重试，直接清理认证状态。
    if (_isRefreshTokenPath(err.requestOptions.path)) {
      await _authService.authenticationFailed();
      return handler.next(err);
    }

    try {
      // 被动刷新：尝试用 refresh token 续期并重试原请求。
      final newToken = await _refreshToken();
      if (newToken == null) {
        // 刷新失败，清除认证状态并跳转登录页。
        await _authService.authenticationFailed();
        return handler.next(err);
      }

      // 使用新令牌重试请求。复用同一 Dio 单例，保证 baseUrl 与拦截器链
      // （如 Content-Type 注入、响应解包等）正常生效。
      final options = err.requestOptions;
      options.headers['Authorization'] = _makeBearerToken(
        accessToken: newToken,
      );

      final dio = GetIt.instance<Dio>();
      final response = await dio.fetch(options);
      return handler.resolve(response);
    } catch (e) {
      fatal('Error refreshing token: $e');
      // 发生异常时清除令牌并传递错误
      await _authService.authenticationFailed();
      return handler.next(err);
    }
  }

  /// 刷新令牌，带并发去重。
  ///
  /// 多个并发请求同时触发刷新时，仅第一个执行实际刷新，其余等待同一个
  /// [Completer.future] 完成后读取已刷新的 access token。
  /// 返回新的 access token，失败时返回 null（状态已由 authenticationFailed
  /// 清理）。
  Future<String?> _refreshToken() async {
    // 已有刷新进行中：等待其完成，复用结果。
    final inflight = _refreshFuture;
    if (inflight != null) {
      await inflight.future;
      return _authService.getAccessToken();
    }

    // 创建新的 Completer 并占位，后续并发请求将等待它。
    final completer = Completer<String?>();
    _refreshFuture = completer;

    try {
      final newToken = await _authService.refreshToken();
      // 完成所有等待方，无论成功失败。
      if (!completer.isCompleted) {
        completer.complete(newToken);
      }
      return newToken;
    } catch (e) {
      // 异常路径也需释放等待方，避免死锁。
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return null;
    } finally {
      // 清除占位，允许后续刷新请求发起新一轮刷新。
      _refreshFuture = null;
    }
  }

  /// 创建Bearer令牌
  String _makeBearerToken({String? accessToken}) {
    return "Bearer ${accessToken ?? ""}";
  }
}
