import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Theme, Scaffold, SafeArea;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/utils/responsive_utils.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/core/widgets/app_button.dart';
import 'package:flutter_app/src/features/ledger/services/ledger_auth_service.dart';
import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerAuthResponse;

/// 注册页面（iOS 风格：圆角填充输入框 + 填充主按钮）
///
/// 调用 [LedgerAuthService.register] 完成用户注册（后端自动创建默认租户和账本），
/// 注册成功后跳转登录页。UI 风格与 [LoginPage] 保持一致。
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _inviteCodeController = TextEditingController(text: '111111');
  final _nickNameController = TextEditingController();
  final _service = LedgerAuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// 密码最小长度
  static const int _minPasswordLength = 6;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeController.dispose();
    _nickNameController.dispose();
    super.dispose();
  }

  /// iOS 输入框通用装饰（灰底圆角，微信/支付宝登录样式）
  BoxDecoration _fieldDecoration(BuildContext context, bool isMobile) =>
      BoxDecoration(
        color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(isMobile ? 12.r : 14),
      );

  Widget _fieldPrefix(IconData icon) => Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Icon(
          icon,
          size: 20,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
      );

  Future<void> _handleRegister() async {
    final loc = S.of(context);
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (username.isEmpty) {
      EasyLoading.showError(loc.usernameHint);
      return;
    }
    if (password.isEmpty) {
      EasyLoading.showError(loc.passwordHint);
      return;
    }
    if (password.length < _minPasswordLength) {
      EasyLoading.showError(loc.passwordMinLength(_minPasswordLength));
      return;
    }
    if (confirmPassword.isEmpty) {
      EasyLoading.showError(loc.confirmPasswordHint);
      return;
    }
    if (confirmPassword != password) {
      EasyLoading.showError(loc.passwordMismatch);
      return;
    }

    EasyLoading.show(status: loc.processing);

    final result = await _service.register(
      username,
      password,
      inviteCode: _inviteCodeController.text.trim().isEmpty
          ? null
          : _inviteCodeController.text.trim(),
      nickName: _nickNameController.text.trim().isEmpty
          ? null
          : _nickNameController.text.trim(),
    );

    EasyLoading.dismiss();
    if (!mounted) return;

    if (result is LedgerAuthResponse) {
      EasyLoading.showSuccess(loc.registerSuccess);
      context.go('/login');
    } else if (result is Status) {
      EasyLoading.showError(
        result.getMessage.isEmpty ? loc.registerFailed : result.getMessage,
      );
    } else {
      EasyLoading.showError(loc.registerFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final loc = S.of(context);
    final secondaryLabel =
        CupertinoColors.secondaryLabel.resolveFrom(context);

    Widget suffixToggle(bool obscure, VoidCallback toggle) => CupertinoButton(
          padding: const EdgeInsets.only(right: 8),
          minimumSize: Size.zero,
          onPressed: toggle,
          child: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: secondaryLabel,
          ),
        );

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
                            Icons.person_add_outlined,
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
                          loc.registerSubtitle,
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
                          prefix: _fieldPrefix(Icons.person_outline),
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
                          prefix: _fieldPrefix(Icons.lock_outline),
                          suffix: suffixToggle(_obscurePassword, () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          }),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: isMobile ? 14.h : 15,
                          ),
                          decoration: _fieldDecoration(context, isMobile),
                        ),
                        SizedBox(height: isMobile ? 16.h : 18),

                        // Confirm Password
                        CupertinoTextField(
                          controller: _confirmPasswordController,
                          placeholder: loc.confirmPasswordHint,
                          obscureText: _obscureConfirmPassword,
                          prefix: _fieldPrefix(Icons.lock_outline),
                          suffix: suffixToggle(_obscureConfirmPassword, () {
                            setState(() => _obscureConfirmPassword =
                                !_obscureConfirmPassword);
                          }),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: isMobile ? 14.h : 15,
                          ),
                          decoration: _fieldDecoration(context, isMobile),
                          onSubmitted: (_) => _handleRegister(),
                        ),
                        SizedBox(height: isMobile ? 16.h : 18),

                        // Nickname (optional)
                        CupertinoTextField(
                          controller: _nickNameController,
                          placeholder: loc.fieldNicknameHint,
                          prefix: _fieldPrefix(Icons.badge_outlined),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: isMobile ? 14.h : 15,
                          ),
                          decoration: _fieldDecoration(context, isMobile),
                        ),
                        SizedBox(height: isMobile ? 16.h : 18),

                        // Invite code (optional, default 111111)
                        CupertinoTextField(
                          controller: _inviteCodeController,
                          placeholder: loc.fieldInviteCodeHint,
                          prefix: _fieldPrefix(Icons.card_giftcard_outlined),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: isMobile ? 14.h : 15,
                          ),
                          decoration: _fieldDecoration(context, isMobile),
                        ),
                        SizedBox(height: isMobile ? 28.h : 32),

                        // Register Button
                        AppFilledButton(
                          label: loc.registerTitle,
                          onPressed: _handleRegister,
                        ),
                        SizedBox(height: isMobile ? 16.h : 18),

                        // 已有账号？去登录
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loc.haveAccount,
                              style: TextStyle(
                                fontSize: isMobile ? 13.sp : 14,
                                color: theme.colorScheme.onSurface
                                    .withAlpha(140),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(
                                loc.goLogin,
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
