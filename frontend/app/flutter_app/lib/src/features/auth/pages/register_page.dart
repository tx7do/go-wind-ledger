import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/utils/responsive_utils.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/ledger_auth_service.dart';
import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerAuthResponse;

/// 注册页面
///
/// 调用 [LedgerAuthService.register] 完成用户注册（后端自动创建默认租户和账本），
/// 注册成功后跳转登录页。UI 风格与 [LoginPage] 保持一致（Material 3）。
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    EasyLoading.show(status: '注册中...');

    final result = await _service.register(
      _usernameController.text.trim(),
      _passwordController.text,
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
      EasyLoading.showSuccess('注册成功');
      context.go('/login');
    } else if (result is Status) {
      EasyLoading.showError(
        result.getMessage.isEmpty ? '注册失败' : result.getMessage,
      );
    } else {
      EasyLoading.showError('注册失败');
    }
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
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => context.go('/'),
                tooltip: loc.backToHome,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface.withAlpha(15),
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
                        color: Colors.black.withAlpha((0.06 * 255).round()),
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
                    child: Form(
                      key: _formKey,
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
                            '创建账号，开启记账之旅',
                            style: TextStyle(
                              fontSize: isMobile ? 13.sp : 14,
                              color: theme.colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                          SizedBox(height: isMobile ? 32.h : 40),

                          // Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: loc.username,
                              hintText: loc.usernameHint,
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  isMobile ? 12.r : 14,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return loc.usernameHint;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isMobile ? 16.h : 18),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: loc.password,
                              hintText: loc.passwordHint,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  isMobile ? 12.r : 14,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return loc.passwordHint;
                              }
                              if (value.length < _minPasswordLength) {
                                return '密码长度不能少于 $_minPasswordLength 位';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isMobile ? 16.h : 18),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: '确认密码',
                              hintText: '请再次输入密码',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  isMobile ? 12.r : 14,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请再次输入密码';
                              }
                              if (value != _passwordController.text) {
                                return '两次输入的密码不一致';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleRegister(),
                          ),
                          SizedBox(height: isMobile ? 16.h : 18),

                          // Nickname (optional)
                          TextFormField(
                            controller: _nickNameController,
                            decoration: InputDecoration(
                              labelText: '昵称（可选）',
                              hintText: '请输入昵称',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  isMobile ? 12.r : 14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 16.h : 18),

                          // Invite code (optional, default 111111)
                          TextFormField(
                            controller: _inviteCodeController,
                            decoration: InputDecoration(
                              labelText: '邀请码（可选）',
                              hintText: '请输入邀请码',
                              prefixIcon:
                                  const Icon(Icons.card_giftcard_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  isMobile ? 12.r : 14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 28.h : 32),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: isMobile ? 48.h : 50,
                            child: FilledButton(
                              onPressed: _handleRegister,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    isMobile ? 12.r : 14,
                                  ),
                                ),
                              ),
                              child: Text(
                                '注册',
                                style: TextStyle(
                                  fontSize: isMobile ? 16.sp : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 16.h : 18),

                          // 已有账号？去登录
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '已有账号？',
                                style: TextStyle(
                                  fontSize: isMobile ? 13.sp : 14,
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(140),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  '去登录',
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
            ),
          ],
        ),
      ),
    );
  }
}
