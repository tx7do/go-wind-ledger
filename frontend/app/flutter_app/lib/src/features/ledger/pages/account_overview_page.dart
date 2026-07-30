import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1OverviewResponse, LedgerServiceV1AccountAsset;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/form_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/themes/semantic_colors.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/account_service.dart';

/// 账户概览页。
class AccountOverviewPage extends StatefulWidget {
  final bool embedded;
  const AccountOverviewPage({super.key, this.embedded = false});

  @override
  State<AccountOverviewPage> createState() => _AccountOverviewPageState();
}

class _AccountOverviewPageState extends State<AccountOverviewPage> {
  final AccountService _service = AccountService();
  LedgerServiceV1OverviewResponse? _overview;

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
    final result = await _service.overview();
    if (result is Status) throw Exception(result.getMessage);
    if (result is LedgerServiceV1OverviewResponse && mounted) {
      setState(() => _overview = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormCubit, FormLoadState>(
      bloc: _formCubit,
      builder: (context, state) => switch (state) {
        FormLoadState.initial || FormLoadState.loading => const Center(child: CircularProgressIndicator()),
        FormLoadState.loaded => _overview == null ? _buildEmpty() : _buildContent(context),
        FormLoadState.error => _buildError(context),
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: Text(loc.accountOverview)),
      body: RefreshIndicator(
        onRefresh: () => _formCubit.loadInitial(_doLoad),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            if (!widget.embedded) const SizedBox(height: 8),
            _buildSummaryCard(theme),
            const SizedBox(height: 8),
            _buildSection(theme, title: loc.assetDetails, icon: Icons.trending_up_outlined, items: _overview!.assets ?? [], valueColor: SemanticColors.income(context)),
            _buildSection(theme, title: loc.debtDetails, icon: Icons.trending_down_outlined, items: _overview!.debts ?? [], valueColor: SemanticColors.expense(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final loc = S.of(context);
    final msg = _formCubit.errorMessage;
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: Text(loc.accountOverview)),
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

  Widget _buildSummaryCard(ThemeData theme) {
    final loc = S.of(context);
    final assets = double.tryParse(_overview!.totalAssets ?? '0') ?? 0;
    final debts = double.tryParse(_overview!.totalDebts ?? '0') ?? 0;
    final net = double.tryParse(_overview!.netWorth ?? '0') ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.account_balance_outlined, color: theme.colorScheme.primary), const SizedBox(width: 8), Text(loc.balanceSheetTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _summaryTile(theme, label: loc.totalAssets, value: assets, color: SemanticColors.income(context), icon: Icons.savings_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _summaryTile(theme, label: loc.totalDebts, value: debts, color: SemanticColors.expense(context), icon: Icons.credit_card_outlined)),
          ]),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: _summaryTile(theme, label: loc.netWorth, value: net, color: theme.colorScheme.primary, icon: Icons.account_balance_wallet_outlined, highlight: true))]),
        ]),
      ),
    );
  }

  Widget _summaryTile(ThemeData theme, {required String label, required double value, required Color color, required IconData icon, bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withAlpha(highlight ? 24 : 12), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withAlpha(60), width: 0.8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))]),
        const SizedBox(height: 6),
        Text(value.toStringAsFixed(2), style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildSection(ThemeData theme, {required String title, required IconData icon, required List<LedgerServiceV1AccountAsset> items, required Color valueColor}) {
    final loc = S.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: valueColor),
        title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(loc.itemCount(items.length)),
        children: items.isEmpty ? [Padding(padding: const EdgeInsets.all(16), child: Text(loc.noData))] : items.map((a) => _buildAssetTile(theme, a, valueColor)).toList(),
      ),
    );
  }

  Widget _buildAssetTile(ThemeData theme, LedgerServiceV1AccountAsset asset, Color valueColor) {
    final loc = S.of(context);
    final balance = double.tryParse(asset.balance ?? '0') ?? 0;
    return ListTile(
      leading: CircleAvatar(backgroundColor: valueColor.withAlpha(30), foregroundColor: valueColor, child: const Icon(Icons.account_balance_wallet_outlined, size: 20)),
      title: Text(asset.name ?? loc.unnamed),
      subtitle: Text([if ((asset.type ?? '').isNotEmpty) asset.type!, if ((asset.currencyCode ?? '').isNotEmpty) asset.currencyCode!].join(' · '), style: theme.textTheme.bodySmall),
      trailing: Text(balance.toStringAsFixed(2), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: valueColor)),
    );
  }

  Widget _buildEmpty() {
    final loc = S.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: Text(loc.accountOverview)),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.account_balance_outlined, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noOverviewData, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back), label: Text(loc.back)),
        ]),
      ),
    );
  }
}
