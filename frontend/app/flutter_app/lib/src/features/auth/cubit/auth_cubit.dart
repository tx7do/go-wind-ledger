import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/src/core/repositories/user_auth_cache.dart'
    show UserAuthCache;
import 'package:flutter_app/src/features/auth/services/authentication_service.dart';

import 'auth_state.dart';

/// 认证状态管理 Cubit
///
/// 监听 [UserAuthCache.loginStateNotifier] 的变化，
/// 自动通知 Widget 树登录/登出状态变更。
class AuthCubit extends Cubit<AuthState> {
  final UserAuthCache _cache = GetIt.instance<UserAuthCache>();
  final AuthenticationService _authService = AuthenticationService();

  AuthCubit() : super(AuthState(isAuthenticated: false)) {
    _init();
  }

  void _init() {
    // 从缓存读取初始登录状态
    final hasLogin = _cache.hasLogin;
    emit(AuthState(isAuthenticated: hasLogin));

    // 监听登录状态变化
    _cache.loginStateNotifier.addListener(_onLoginStateChanged);
  }

  void _onLoginStateChanged() {
    emit(AuthState(isAuthenticated: _cache.hasLogin));
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      await _authService.logoutMutation().mutate(null);
    } catch (_) {
      // 即使 API 调用失败，也清除本地缓存
      await _cache.clearTokens();
    }
  }

  @override
  Future<void> close() {
    _cache.loginStateNotifier.removeListener(_onLoginStateChanged);
    return super.close();
  }
}
