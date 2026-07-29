import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show InitStateResponse, LedgerServiceV1Book, IdentityServiceV1Tenant;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/core/themes/cubit/app_theme_cubit.dart';
import 'package:flutter_app/src/features/ledger/services/ledger_auth_service.dart';
import 'package:flutter_app/src/features/auth/cubit/auth_cubit.dart';

/// 记账设置页。
///
/// 展示当前默认租户 / 默认账本，并提供切换入口。切换时调用
/// [LedgerAuthService.setDefaultTenant] / [LedgerAuthService.setDefaultBook]，
/// 操作结果通过 flutter_easyloading 反馈。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final LedgerAuthService _authService = LedgerAuthService();

  InitStateResponse? _state;
  List<IdentityServiceV1Tenant> _tenants = [];
  List<LedgerServiceV1Book> _books = [];
  int? _tenantId;
  int? _bookId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    final result = await _authService.initState();
    if (!mounted) return;
    if (result is InitStateResponse) {
      final tenants = result.availableTenants ?? [];
      final books = result.availableBooks ?? [];
      final tenantIds = tenants.map((t) => t.id).toSet();
      final bookIds = books.map((b) => b.id).toSet();
      // 仅当下拉列表中包含当前默认值时才选中，避免 DropdownButton 断言失败。
      final tenantId = (result.tenant?.id != null &&
              tenantIds.contains(result.tenant!.id))
          ? result.tenant!.id
          : (tenants.isNotEmpty ? tenants.first.id : null);
      final bookId = (result.book?.id != null &&
              bookIds.contains(result.book!.id))
          ? result.book!.id
          : (books.isNotEmpty ? books.first.id : null);
      setState(() {
        _state = result;
        _tenants = tenants;
        _books = books;
        _tenantId = tenantId;
        _bookId = bookId;
        _loading = false;
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(
          result.getMessage.isEmpty ? '加载失败' : result.getMessage);
    }
  }

  Future<void> _switchTenant(int? tenantId) async {
    if (tenantId == null || tenantId == _tenantId) return;
    EasyLoading.show(status: '切换中...');
    final result = await _authService.setDefaultTenant(tenantId);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is Status) {
      EasyLoading.showError(
          result.getMessage.isEmpty ? '切换失败' : result.getMessage);
      return;
    }
    EasyLoading.showSuccess('默认租户已切换');
    await _loadInitial();
  }

  Future<void> _switchBook(int? bookId) async {
    if (bookId == null || bookId == _bookId) return;
    EasyLoading.show(status: '切换中...');
    final result = await _authService.setDefaultBook(bookId);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is Status) {
      EasyLoading.showError(
          result.getMessage.isEmpty ? '切换失败' : result.getMessage);
      return;
    }
    EasyLoading.showSuccess('默认账本已切换');
    await _loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitial,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _buildUserCard(theme),
                  _buildThemeModeSwitcher(theme),
                  _buildColorPicker(theme),
                  _buildLanguageSwitcher(theme),
                  _buildSectionHeader(theme, '当前默认'),
                  _buildInfoTile(
                    theme,
                    icon: Icons.apartment_outlined,
                    label: '默认租户',
                    value: _state?.tenant?.name ?? '未设置',
                  ),
                  _buildInfoTile(
                    theme,
                    icon: Icons.menu_book_outlined,
                    label: '默认账本',
                    value: _state?.book?.name ?? '未设置',
                  ),
                  _buildTenantSwitcher(theme),
                  _buildBookSwitcher(theme),
                  _buildLogoutSection(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildUserCard(ThemeData theme) {
    final user = _state?.user;
    final displayName = (user?.nickname?.isNotEmpty == true)
        ? user!.nickname!
        : (user?.username ?? '未登录');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.person_outline),
        ),
        title: Text(displayName),
        subtitle: Text(
          (user?.username ?? '').isNotEmpty ? '@${user!.username}' : '',
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoTile(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label, style: theme.textTheme.bodySmall),
        subtitle: Text(
          value,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTenantSwitcher(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '切换默认租户',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _tenantId,
            decoration: const InputDecoration(
              labelText: '默认租户',
              prefixIcon: Icon(Icons.apartment_outlined),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _tenants
                .map((t) => DropdownMenuItem<int>(
                      value: t.id,
                      child: Text(t.name ?? '未命名租户'),
                    ))
                .toList(),
            onChanged: _switchTenant,
          ),
        ],
      ),
    );
  }

  Widget _buildBookSwitcher(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '切换默认账本',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _bookId,
            decoration: const InputDecoration(
              labelText: '默认账本',
              prefixIcon: Icon(Icons.menu_book_outlined),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _books
                .map((b) => DropdownMenuItem<int>(
                      value: b.id,
                      child: Text(b.name ?? '未命名账本'),
                    ))
                .toList(),
            onChanged: _switchBook,
          ),
        ],
      ),
    );
  }

  // ─── 主题 & 语言设置 ─────────────────────────────

  static const _seedColors = [
    Color(0xFF3A7CA5), // 海蓝（默认）
    Color(0xFF2E7D32), // 森林绿
    Color(0xFF7B1FA2), // 深紫
    Color(0xFFE65100), // 暖橙
    Color(0xFF00838F), // 青蓝
    Color(0xFFC62828), // 赤红
  ];

  Widget _buildThemeModeSwitcher(ThemeData theme) {
    final cubit = context.watch<AppThemeCubit>();
    final currentMode = cubit.themeMode;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.brightness_6_outlined,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('主题模式',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined, size: 18),
                  label: Text('亮色'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined, size: 18),
                  label: Text('暗色'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_suggest_outlined, size: 18),
                  label: Text('跟随系统'),
                ),
              ],
              selected: {currentMode},
              onSelectionChanged: (mode) => cubit.modify(mode.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(ThemeData theme) {
    final cubit = context.watch<AppThemeCubit>();
    final currentColor = cubit.currentSeedColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('主题色',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: _seedColors.map((color) {
                final isSelected = currentColor.value == color.value;
                return GestureDetector(
                  onTap: () => cubit.modifySeedColor(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withAlpha(100),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher(ThemeData theme) {
    final cubit = context.watch<AppThemeCubit>();
    final currentLocale = cubit.currentLocale;
    final supported = cubit.supportedLocales;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.translate_outlined,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('语言',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<Locale>(
              segments: supported.map((locale) {
                final label = locale.languageCode == 'zh' ? '中文' : 'English';
                return ButtonSegment(value: locale, label: Text(label));
              }).toList(),
              selected: {currentLocale},
              onSelectionChanged: (locale) =>
                  cubit.modifyLocale(locale.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 退出登录 ──────────────────────────────────

  Widget _buildLogoutSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () => _handleLogout(),
          icon: const Icon(Icons.logout, size: 20),
          label: const Text('退出登录'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error.withAlpha(100)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('退出登录后需要重新登录才能使用。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<AuthCubit>().logout();
              if (!mounted) return;
              context.go('/login');
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}
