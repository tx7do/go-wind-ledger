import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Theme, Scaffold, SafeArea;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cached_query/cached_query.dart' show MutationSuccess;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/utils/responsive_utils.dart';
import 'package:flutter_app/src/core/widgets/app_button.dart';
import 'package:flutter_app/src/features/auth/services/authentication_service.dart';
import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show AuthenticationServiceV1LoginResponse;

/// 登录页面（iOS 风格：圆角填充输入框 + 填充主按钮）
class LoginPage extends StatefulWidget {
  /// 登录成功后重定向到的路径（由路由守卫传入）
  final String? redirectTo;

  const LoginPage({super.key, this.redirectTo});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthenticationService();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// iOS 输入框通用装饰（灰底圆角，微信/支付宝登录样式）
  BoxDecoration _fieldDecoration(BuildContext context, bool isMobile) =>
      BoxDecoration(
        color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(isMobile ? 12.r : 14),
      );

  Future<void> _handleLogin() async {
    final loc = S.of(context);
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty) {
      EasyLoading.showError(loc.usernameHint);
      return;
    }
    if (password.isEmpty) {
      EasyLoading.showError(loc.passwordHint);
      return;
    }

    final mutation = _authService.loginMutation();
    try {
      final result = await mutation.mutate(
        LoginParams(username: username, password: password),
      );

      if (!mounted) return;

      if (result is MutationSuccess<AuthenticationServiceV1LoginResponse?> &&
          result.data != null) {
        EasyLoading.showSuccess(loc.loginSuccess);
        // 登录后回跳到来源页面（或默认首页）
        final redirect = (widget.redirectTo != null &&
                widget.redirectTo!.isNotEmpty)
            ? widget.redirectTo!
            : '/';
        context.go(redirect);
      } else {
        _showLoginFailed();
      }
    } catch (e) {
      if (!mounted) return;
      _showLoginFailed();
    }
  }

  void _showLoginFailed() {
    EasyLoading.showError(S.of(context).loginFailed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final loc = S.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // 返回按钮
            Positioned(
              top: isMobile ? 8 : 16,
              left: isMobile ? 8 : 16,
              child: CupertinoButton(
                padding: const EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.onSurface.withAlpha(15),
                onPressed: () => context.go('/'),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            // 主内容：居中卡片
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24.w : 48,
                  vertical: isMobile ? 32.h : 48,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : 420,
                  ),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(isMobile ? 20.r : 24),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withAlpha((0.06 * 255).round()),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 28.w : 40,
                      vertical: isMobile ? 32.h : 48,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: isMobile ? 64.w : 72,
                          height: isMobile ? 64.w : 72,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(
                              isMobile ? 18.r : 20,
                            ),
                          ),
                          child: Icon(
                            Icons.article_outlined,
                            size: isMobile ? 32.sp : 36,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: isMobile ? 20.h : 24),
                        Text(
                          loc.appName,
                          style: TextStyle(
                            fontSize: isMobile ? 22.sp : 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: isMobile ? 4.h : 6),
                        Text(
                          loc.loginForMore,
                          style: TextStyle(
                            fontSize: isMobile ? 13.sp : 14,
                            color: theme.colorScheme.onSurface.withAlpha(140),
                          ),
                        ),
                        SizedBox(height: isMobile ? 32.h : 40),

                        // Username
                        CupertinoTextField(
                          controller: _usernameController,
                          placeholder: loc.usernameHint,
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: Icon(
                              Icons.person_outline,
                              size: 20,
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: isMobile ? 14.h : 15,
                          ),
                          decoration: _fieldDecoration(context, isMobile),
                        ),
                        SizedBox(height: isMobile ? 16.h : 18),

                        // Password
                        CupertinoTextField(
                          controller: _passwordController,
                          placeholder: loc.passwordHint,
                          obscureText: _obscurePassword,
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: Icon(
                              Icons.lock_outline,
                              size: 20,
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                            ),
                          ),
                          suffix: CupertinoButton(
                            padding: const EdgeInsets.only(right: 8),
                            minimumSize: Size.zero,
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: isMobile ? 14.h : 15,
                          ),
                          decoration: _fieldDecoration(context, isMobile),
                          onSubmitted: (_) => _handleLogin(),
                        ),
                        SizedBox(height: isMobile ? 28.h : 32),

                        // Login Button
                        AppFilledButton(
                          label: loc.loginButton,
                          onPressed: _handleLogin,
                        ),
                        SizedBox(height: isMobile ? 16.h : 18),

                        // 没有账号？去注册
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loc.noAccount,
                              style: TextStyle(
                                fontSize: isMobile ? 13.sp : 14,
                                color: theme.colorScheme.onSurface
                                    .withAlpha(140),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/register'),
                              child: Text(
                                loc.goRegister,
                                style: TextStyle(
                                  fontSize: isMobile ? 13.sp : 14,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
