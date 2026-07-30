import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/utils/responsive_utils.dart';
import 'package:flutter_app/src/features/ledger/widgets/ledger_bottom_nav.dart';
import 'package:flutter_app/src/features/ledger/pages/balance_flow_list_page.dart';
import 'package:flutter_app/src/features/ledger/pages/report_page.dart';
import 'package:flutter_app/src/features/ledger/pages/account_list_page.dart';

/// 记账模块主框架。
///
/// 底部导航 4 个 Tab（流水/统计/账户/我的）+ 中间“记一笔”浮动按钮。
class LedgerHomePage extends StatefulWidget {
  /// 初始展示的 Tab，默认流水。
  final LedgerTab initialTab;

  const LedgerHomePage({super.key, this.initialTab = LedgerTab.flows});

  @override
  State<LedgerHomePage> createState() => _LedgerHomePageState();
}

class _LedgerHomePageState extends State<LedgerHomePage> {
  late LedgerTab _current = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.contentMaxWidth(context),
          ),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: LedgerBottomNav(
        current: _current,
        onTap: (tab) => setState(() => _current = tab),
      ),
      floatingActionButton:
          _current == LedgerTab.flows
              ? FloatingActionButton(
                  onPressed: () => context.push('/ledger/flows/create'),
                  tooltip: S.of(context).flowCreate,
                  child: const Icon(Icons.add),
                )
              : null,
      floatingActionButtonLocation:
          _current == LedgerTab.flows
              ? FloatingActionButtonLocation.endFloat
              : null,
    );
  }

  Widget _buildBody() {
    switch (_current) {
      case LedgerTab.flows:
        return const BalanceFlowListPage(embedded: true);
      case LedgerTab.statistics:
        return const ReportPage(embedded: true);
      case LedgerTab.accounts:
        return const AccountListPage(embedded: true);
      case LedgerTab.mine:
        return _buildMinePage();
    }
  }

  Widget _buildMinePage() {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final entries = <_MenuEntry>[
      _MenuEntry(
        icon: Icons.menu_book_outlined,
        title: loc.bookManagement,
        subtitle: loc.manageBooksDesc,
        route: '/ledger/books',
      ),
      _MenuEntry(
        icon: Icons.savings_outlined,
        title: loc.budgetManagement,
        subtitle: loc.manageBudgetsDesc,
        route: '/ledger/budgets',
      ),
      _MenuEntry(
        icon: Icons.group_outlined,
        title: loc.memberManagement,
        subtitle: loc.manageMembersDesc,
        route: '/ledger/members',
      ),
      _MenuEntry(
        icon: Icons.category_outlined,
        title: loc.categoryManagement,
        subtitle: loc.manageCategoriesDesc,
        route: '/ledger/categories',
      ),
      _MenuEntry(
        icon: Icons.label_outlined,
        title: loc.tagManagement,
        subtitle: loc.manageTagsDesc,
        route: '/ledger/tags',
      ),
      _MenuEntry(
        icon: Icons.person_outline,
        title: loc.payeeManagement,
        subtitle: loc.managePayeesDesc,
        route: '/ledger/payees',
      ),
      _MenuEntry(
        icon: Icons.notifications_active_outlined,
        title: loc.noteDayManagement,
        subtitle: loc.manageNoteDaysDesc,
        route: '/ledger/note-days',
      ),
      _MenuEntry(
        icon: Icons.currency_exchange_outlined,
        title: loc.currencyManagement,
        subtitle: loc.manageCurrenciesDesc,
        route: '/ledger/currencies',
      ),
      _MenuEntry(
        icon: Icons.settings_outlined,
        title: loc.mySettings,
        subtitle: loc.switchDefaultTenant,
        route: '/ledger/settings',
      ),
    ];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              loc.myProfile,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...entries.map((e) => _buildMenuTile(theme, e)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(ThemeData theme, _MenuEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(entry.icon, color: theme.colorScheme.primary),
        title: Text(entry.title),
        subtitle: Text(
          entry.subtitle,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(entry.route),
      ),
    );
  }
}

class _MenuEntry {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _MenuEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}
