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
import 'package:flutter_app/src/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_app/src/features/ledger/services/ledger_auth_service.dart';

/// 记账设置页。
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
        FormLoadState.initial || FormLoadState.loading => const Center(child: CircularProgressIndicator()),
        FormLoadState.loaded => _buildContent(context),
        FormLoadState.error => _buildError(context),
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: RefreshIndicator(
        onRefresh: () => _formCubit.loadInitial(_doLoad),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveUtils.contentMaxWidth(context)),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildUserCard(theme, loc),
                _buildThemeModeSwitcher(theme, loc),
                _buildColorPicker(theme, loc),
                _buildLanguageSwitcher(theme, loc),
                _buildSectionHeader(theme, loc.currentDefault),
                _buildInfoTile(theme, icon: Icons.apartment_outlined, label: loc.defaultTenant, value: _state?.tenant?.name ?? loc.notSet),
                _buildInfoTile(theme, icon: Icons.menu_book_outlined, label: loc.defaultBook, value: _state?.book?.name ?? loc.notSet),
                _buildTenantSwitcher(theme, loc),
                _buildBookSwitcher(theme, loc),
                _buildLogoutSection(theme, loc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final loc = S.of(context);
    final msg = _formCubit.errorMessage;
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(msg.isNotEmpty ? msg : loc.loadFailed,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: () => _formCubit.loadInitial(_doLoad), icon: const Icon(Icons.refresh), label: Text(loc.retry)),
          ],
        ),
      ),
    );
  }

  // ---- UI helpers (unchanged below) ----

  Widget _buildUserCard(ThemeData theme, S loc) {
    final user = _state?.user;
    final displayName = (user?.nickname?.isNotEmpty == true) ? user!.nickname! : (user?.username ?? loc.unknownUser);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, foregroundColor: theme.colorScheme.onPrimaryContainer, child: const Icon(Icons.person_outline)),
        title: Text(displayName),
        subtitle: Text((user?.username ?? '').isNotEmpty ? '@${user!.username}' : '', style: theme.textTheme.bodySmall),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoTile(ThemeData theme, {required IconData icon, required String label, required String value}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label, style: theme.textTheme.bodySmall),
        subtitle: Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildTenantSwitcher(ThemeData theme, S loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(loc.switchDefaultTenant, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _tenantId,
          decoration: InputDecoration(labelText: loc.defaultTenant, prefixIcon: const Icon(Icons.apartment_outlined), border: const OutlineInputBorder(), isDense: true),
          items: _tenants.map((t) => DropdownMenuItem<int>(value: t.id, child: Text(t.name ?? loc.unnamed))).toList(),
          onChanged: _switchTenant,
        ),
      ]),
    );
  }

  Widget _buildBookSwitcher(ThemeData theme, S loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(loc.switchDefaultBook, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _bookId,
          decoration: InputDecoration(labelText: loc.defaultBook, prefixIcon: const Icon(Icons.menu_book_outlined), border: const OutlineInputBorder(), isDense: true),
          items: _books.map((b) => DropdownMenuItem<int>(value: b.id, child: Text(b.name ?? loc.unnamed))).toList(),
          onChanged: _switchBook,
        ),
      ]),
    );
  }

  // ─── 主题 & 语言 ─────────────────────────────

  static const _seedColors = [
    Color(0xFF3A7CA5), Color(0xFF2E7D32), Color(0xFF7B1FA2),
    Color(0xFFE65100), Color(0xFF00838F), Color(0xFFC62828),
  ];

  Widget _buildThemeModeSwitcher(ThemeData theme, S loc) {
    final cubit = context.watch<AppThemeCubit>();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.brightness_6_outlined, size: 20, color: theme.colorScheme.primary), const SizedBox(width: 8), Text(loc.themeMode, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode_outlined, size: 18), label: Text(loc.light)),
              ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode_outlined, size: 18), label: Text(loc.dark)),
              ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.settings_suggest_outlined, size: 18), label: Text(loc.followSystem)),
            ],
            selected: {cubit.themeMode},
            onSelectionChanged: (mode) => cubit.modify(mode.first),
            style: ButtonStyle(visualDensity: VisualDensity.compact, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ),
        ]),
      ),
    );
  }

  Widget _buildColorPicker(ThemeData theme, S loc) {
    final cubit = context.watch<AppThemeCubit>();
    final currentColor = cubit.currentSeedColor;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
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

  Widget _buildLanguageSwitcher(ThemeData theme, S loc) {
    final cubit = context.watch<AppThemeCubit>();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.translate_outlined, size: 20, color: theme.colorScheme.primary), const SizedBox(width: 8), Text(loc.language, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          SegmentedButton<Locale>(
            segments: cubit.supportedLocales.map((locale) {
              return ButtonSegment(value: locale, label: Text(locale.languageCode == 'zh' ? loc.languageZh : 'English'));
            }).toList(),
            selected: {cubit.currentLocale},
            onSelectionChanged: (locale) => cubit.modifyLocale(locale.first),
            style: ButtonStyle(visualDensity: VisualDensity.compact, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ),
        ]),
      ),
    );
  }

  Widget _buildLogoutSection(ThemeData theme, S loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: SizedBox(
        width: double.infinity, height: 48,
        child: OutlinedButton.icon(
          onPressed: () => _handleLogout(loc),
          icon: const Icon(Icons.logout, size: 20), label: Text(loc.logout),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error.withAlpha(100)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  void _handleLogout(S loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.logoutConfirmTitle),
        content: Text(loc.logoutConfirmMsg),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(loc.cancel)),
          FilledButton(onPressed: () async {
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
