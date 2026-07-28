import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      body: _buildBody(),
      bottomNavigationBar: LedgerBottomNav(
        current: _current,
        onTap: (tab) => setState(() => _current = tab),
        onCreate: () => context.push('/ledger/flows/create'),
      ),
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
    final entries = <_MenuEntry>[
      _MenuEntry(
        icon: Icons.menu_book_outlined,
        title: '账本管理',
        subtitle: '管理记账账本',
        route: '/ledger/books',
      ),
      _MenuEntry(
        icon: Icons.category_outlined,
        title: '分类管理',
        subtitle: '管理收支分类',
        route: '/ledger/categories',
      ),
      _MenuEntry(
        icon: Icons.label_outlined,
        title: '标签管理',
        subtitle: '管理流水标签',
        route: '/ledger/tags',
      ),
      _MenuEntry(
        icon: Icons.person_outline,
        title: '收款人管理',
        subtitle: '管理收款人信息',
        route: '/ledger/payees',
      ),
      _MenuEntry(
        icon: Icons.notifications_active_outlined,
        title: '定期提醒',
        subtitle: '管理定期记账提醒',
        route: '/ledger/note-days',
      ),
      _MenuEntry(
        icon: Icons.currency_exchange_outlined,
        title: '币种管理',
        subtitle: '查看币种与汇率',
        route: '/ledger/currencies',
      ),
    ];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              '我的',
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
