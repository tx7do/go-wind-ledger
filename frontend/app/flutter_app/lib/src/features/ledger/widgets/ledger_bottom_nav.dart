import 'package:flutter/material.dart';

import 'package:flutter_app/generated/l10n.dart';

/// 记账模块底部导航栏的目标 Tab。
enum LedgerTab { flows, statistics, accounts, mine }

/// 记账模块底部导航栏。
///
/// 使用 MD3 标准 [NavigationBar]，4 个等宽 Tab（流水/统计/账户/我的）。
/// 颜色、选中态指示器、动效全部由 [NavigationBarThemeData]（已存在于
/// light/dark theme）接管，随主题色联动，无需手写颜色。
///
/// “记一笔”入口由宿主 [Scaffold] 的 [FloatingActionButton] 承担
/// （见 [LedgerHomePage]），不再嵌入导航栏。
class LedgerBottomNav extends StatelessWidget {
  /// 当前选中的 Tab。
  final LedgerTab current;

  /// Tab 切换回调。
  final ValueChanged<LedgerTab> onTap;

  const LedgerBottomNav({
    super.key,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final index = current.index;
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) => onTap(LedgerTab.values[i]),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.receipt_long_outlined),
          selectedIcon: const Icon(Icons.receipt_long),
          label: loc.flowListTitle,
        ),
        NavigationDestination(
          icon: const Icon(Icons.pie_chart_outline),
          selectedIcon: const Icon(Icons.pie_chart),
          label: loc.reportTitle,
        ),
        NavigationDestination(
          icon: const Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: const Icon(Icons.account_balance_wallet),
          label: loc.accountOverview,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: loc.myProfile,
        ),
      ],
    );
  }
}
