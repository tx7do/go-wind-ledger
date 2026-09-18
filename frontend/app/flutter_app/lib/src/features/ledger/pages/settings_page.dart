import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show InitStateResponse, LedgerServiceV1Book, IdentityServiceV1Tenant;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/form_cubit.dart';
import 'package:flutter_app/src/core/themes/cubit/app_theme_cubit.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/core/utils/responsive_utils.dart';
import 'package:flutter_app/src/core/widgets/app_button.dart';
import 'package:flutter_app/src/core/widgets/app_form_rows.dart';
import 'package:flutter_app/src/core/widgets/app_pull_refresh.dart';
import 'package:flutter_app/src/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_app/src/features/ledger/services/ledger_auth_service.dart';

/// 记账设置页（iOS 分组列表风格）。
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

  late final FormCubit _formCubit;

  @override
  void initState() {
    super.initState();
    _formCubit = FormCubit()..loadInitial(_doLoad);
  }

  @override
  void dispose() {
    _formCubit.close();
    super.dispose();
  }

  Future<void> _doLoad() async {
    final result = await _authService.initState();
    if (!mounted) return;
    if (result is InitStateResponse) {
      final tenants = result.availableTenants ?? [];
      final books = result.availableBooks ?? [];
      final tenantIds = tenants.map((t) => t.id).toSet();
      final bookIds = books.map((b) => b.id).toSet();
      final tenantId = (result.tenant?.id != null && tenantIds.contains(result.tenant!.id))
          ? result.tenant!.id : (tenants.isNotEmpty ? tenants.first.id : null);
      final bookId = (result.book?.id != null && bookIds.contains(result.book!.id))
          ? result.book!.id : (books.isNotEmpty ? books.first.id : null);
      setState(() { _state = result; _tenants = tenants; _books = books; _tenantId = tenantId; _bookId = bookId; });
    } else if (result is Status) {
      throw Exception(result.getMessage);
    }
  }

  Future<void> _switchTenant(int? tenantId) async {
    if (tenantId == null || tenantId == _tenantId) return;
    EasyLoading.show(status: S.of(context).switching);
    final result = await _authService.setDefaultTenant(tenantId);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? S.of(context).switchFailed : result.getMessage);
      return;
    }
    EasyLoading.showSuccess(S.of(context).tenantSwitched);
    _formCubit.loadInitial(_doLoad);
  }

  Future<void> _switchBook(int? bookId) async {
    if (bookId == null || bookId == _bookId) return;
    EasyLoading.show(status: S.of(context).switching);
    final result = await _authService.setDefaultBook(bookId);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? S.of(context).switchFailed : result.getMessage);
      return;
    }
    EasyLoading.showSuccess(S.of(context).bookSwitched);
    _formCubit.loadInitial(_doLoad);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormCubit, FormLoadState>(
      bloc: _formCubit,
      builder: (context, state) => switch (state) {
        FormLoadState.initial || FormLoadState.loading || FormLoadState.saving => const Center(child: CupertinoActivityIndicator()),
        FormLoadState.loaded => _buildContent(context),
        FormLoadState.error => _buildError(context),
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      appBar: CupertinoNavigationBar(middle: Text(loc.settings)),
      body: AppPullRefresh(
        onRefresh: () => _formCubit.loadInitial(_doLoad),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveUtils.contentMaxWidth(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUserCard(context),
                  _buildThemeModeSwitcher(context),
                  _buildColorPicker(context),
                  _buildLanguageSwitcher(context),
                  _buildSectionHeader(context, loc.currentDefault),
                  _buildInfoTile(context, icon: Icons.apartment_outlined, label: loc.defaultTenant, value: _state?.tenant?.name ?? loc.notSet),
                  _buildInfoTile(context, icon: Icons.menu_book_outlined, label: loc.defaultBook, value: _state?.book?.name ?? loc.notSet),
                  _buildTenantSwitcher(context),
                  _buildBookSwitcher(context),
                  _buildLogoutSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final loc = S.of(context);
    final msg = _formCubit.errorMessage;
    return Scaffold(
      appBar: CupertinoNavigationBar(middle: Text(loc.settings)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(msg.isNotEmpty ? msg : loc.loadFailed,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 16),
            AppGhostButton(
              label: loc.retry,
              icon: Icons.refresh,
              onPressed: () => _formCubit.loadInitial(_doLoad),
            ),
          ],
        ),
      ),
    );
  }

  // ---- UI helpers ----

  Widget _buildUserCard(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final user = _state?.user;
    final displayName = (user?.nickname?.isNotEmpty == true) ? user!.nickname! : (user?.username ?? loc.unknownUser);
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          leading: CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, foregroundColor: theme.colorScheme.onPrimaryContainer, child: const Icon(Icons.person_outline)),
          title: Text(displayName),
          subtitle: Text((user?.username ?? '').isNotEmpty ? '@${user!.username}' : '', style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String label, required String value}) {
    final theme = Theme.of(context);
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(label, style: theme.textTheme.bodySmall),
          subtitle: Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  /// 通用底部滚轮选择器（租户/账本切换共用）。
  Future<void> _showIdPicker<T>({
    required List<T> items,
    required T? current,
    required String Function(T) labelOf,
    required ValueChanged<T> onPicked,
  }) async {
    final loc = S.of(context);
    if (items.isEmpty) return;
    T? selected = current;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      loc.confirm,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoTheme.of(ctx).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: (current != null && items.contains(current)) ? items.indexOf(current) : 0,
                  ),
                  itemExtent: 40,
                  useMagnifier: true,
                  magnification: 1.05,
                  onSelectedItemChanged: (i) => selected = items[i],
                  children: items
                      .map((v) => Center(child: Text(labelOf(v), style: const TextStyle(fontSize: 18))))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && selected != current) onPicked(selected as T);
  }

  T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  Widget _buildTenantSwitcher(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(loc.switchDefaultTenant, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          onPressed: () => _showIdPicker<IdentityServiceV1Tenant>(
            items: _tenants,
            current: _firstWhereOrNull(_tenants, (t) => t.id == _tenantId),
            labelOf: (t) => t.name ?? loc.unnamed,
            onPicked: (t) => _switchTenant(t.id),
          ),
          child: Row(
            children: [
              Icon(Icons.apartment_outlined, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _firstWhereOrNull(_tenants, (t) => t.id == _tenantId)?.name ?? loc.notSet,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const CupertinoListTileChevron(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildBookSwitcher(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(loc.switchDefaultBook, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          onPressed: () => _showIdPicker<LedgerServiceV1Book>(
            items: _books,
            current: _firstWhereOrNull(_books, (b) => b.id == _bookId),
            labelOf: (b) => b.name ?? loc.unnamed,
            onPicked: (b) => _switchBook(b.id),
          ),
          child: Row(
            children: [
              Icon(Icons.menu_book_outlined, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _firstWhereOrNull(_books, (b) => b.id == _bookId)?.name ?? loc.notSet,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const CupertinoListTileChevron(),
            ],
          ),
        ),
      ]),
    );
  }

  // ─── 主题 & 语言 ─────────────────────────────

  static const _seedColors = [
    Color(0xFF3A7CA5), Color(0xFF2E7D32), Color(0xFF7B1FA2),
    Color(0xFFE65100), Color(0xFF00838F), Color(0xFFC62828),
  ];

  Widget _buildThemeModeSwitcher(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final cubit = context.watch<AppThemeCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.brightness_6_outlined, size: 20, color: theme.colorScheme.primary), const SizedBox(width: 8), Text(loc.themeMode, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          CupertinoSlidingSegmentedControl<ThemeMode>(
            groupValue: cubit.themeMode,
            onValueChanged: (mode) { if (mode != null) cubit.modify(mode); },
            children: {
              ThemeMode.light: _segmentIconText(Icons.light_mode_outlined, loc.light),
              ThemeMode.dark: _segmentIconText(Icons.dark_mode_outlined, loc.dark),
              ThemeMode.system: _segmentIconText(Icons.settings_suggest_outlined, loc.followSystem),
            },
          ),
        ]),
      ),
    );
  }

  Widget _segmentIconText(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final cubit = context.watch<AppThemeCubit>();
    final currentColor = cubit.currentSeedColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.palette_outlined, size: 20, color: theme.colorScheme.primary), const SizedBox(width: 8), Text(loc.themeColor, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          Wrap(spacing: 16, runSpacing: 12, children: _seedColors.map((color) {
            final isSelected = currentColor.value == color.value;
            return GestureDetector(
              onTap: () => cubit.modifySeedColor(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200), width: 36, height: 36,
                decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? theme.colorScheme.onSurface : Colors.transparent, width: 3),
                  boxShadow: isSelected ? [BoxShadow(color: color.withAlpha(100), blurRadius: 8, spreadRadius: 1)] : null,
                ),
                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
              ),
            );
          }).toList()),
        ]),
      ),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final cubit = context.watch<AppThemeCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.translate_outlined, size: 20, color: theme.colorScheme.primary), const SizedBox(width: 8), Text(loc.language, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          CupertinoSlidingSegmentedControl<Locale>(
            groupValue: cubit.currentLocale,
            onValueChanged: (locale) { if (locale != null) cubit.modifyLocale(locale); },
            children: {
              for (final locale in cubit.supportedLocales)
                locale: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    locale.languageCode == 'zh' ? loc.languageZh : 'English',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: AppFilledButton(
        label: S.of(context).logout,
        icon: Icons.logout,
        destructive: true,
        onPressed: () => _handleLogout(S.of(context)),
      ),
    );
  }

  void _handleLogout(S loc) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(loc.logoutConfirmTitle),
        content: Text(loc.logoutConfirmMsg),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.of(ctx).pop(), child: Text(loc.cancel)),
          CupertinoDialogAction(onPressed: () async {
            Navigator.of(ctx).pop();
            await context.read<AuthCubit>().logout();
            if (!mounted) return;
            context.go('/login');
          }, child: Text(loc.logout)),
        ],
      ),
    );
  }
}
