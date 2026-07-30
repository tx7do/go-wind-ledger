import 'package:dio/dio.dart' show DioException;
import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/src/core/repositories/user_auth_cache.dart';
import 'package:flutter_app/src/core/services/service_result.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/core/utilities/logger.dart';

abstract class BaseService {
  final Logger _logger;

  BaseService({String tag = 'Service'}) : _logger = Logger(tag);

  Logger get logger => _logger;

  int get currentUserId {
    return GetIt.instance<UserAuthCache>().userId;
  }

  String get mqttClientId {
    return GetIt.instance<UserAuthCache>().mqttClientId;
  }

  /// 将 DioException 统一转换为 Status 对象
  ///
  /// 所有继承 BaseService 的 service 都可直接使用。
  /// Retrofit/Dio 在服务端返回非 2xx 时会抛出 DioException，
  /// 通过此方法可将其转为业务层可判断的 Status。
  ///
  /// 用法：
  /// ```dart
  /// try {
  ///   final response = await _api.someMethod(body: request);
  ///   return response;
  /// } on DioException catch (e) {
  ///   return handleDioError(e);
  /// }
  /// ```
  Status handleDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return Status(
        code: e.response?.statusCode,
        reason: data['reason'] as String?,
        message: data['message'] as String? ?? e.message,
        metadata: data['metadata'] != null
            ? Map<String, String>.from(data['metadata'] as Map)
            : null,
      );
    }

    return Status(
      code: e.response?.statusCode,
      reason: e.type.name,
      message: e.message,
    );
  }

  /// 包装一次 API 调用，自动处理 [DioException] 并返回原始结果或 [Status]。
  ///
  /// 用于消除服务方法中的手写 try-catch 模板。
  /// ```dart
  /// Future<dynamic> listAll() => call(() => _api.listAll(request));
  /// ```
  Future<dynamic> call(Future<dynamic> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 包装一次 API 调用，自动处理 [DioException] 并返回 [ServiceResult]。
  ///
  /// 相比 [call]，提供强类型返回（后续迁移目标）。
  /// ```dart
  /// Future<ServiceResult<ListBookResponse>> listAll() =>
  ///     apiCall(() => _api.listAll(request));
  /// ```
  Future<ServiceResult<T>> apiCall<T>(Future<dynamic> Function() call) async {
    try {
      final result = await call();
      if (result is Status) return Failure(result);
      return Success(result as T);
    } on DioException catch (e) {
      return Failure(handleDioError(e));
    }
  }
}
