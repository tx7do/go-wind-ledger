import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_app/generated/l10n.dart';

/// 记账模块底部导航栏的目标 Tab。
enum LedgerTab { flows, statistics, accounts, mine }

/// 记账模块底部导航栏。
///
/// 使用 iOS 风格 [CupertinoTabBar]，4 个等宽 Tab（流水/统计/账户/我的）。
/// 选中/未选中前景色由 [CupertinoTheme]（桥接 Material 种子色）与系统默认灰决定，
/// 随主题色联动，无需手写颜色。
///
/// “记一笔”入口由 [BalanceFlowListPage] 的 [CupertinoNavigationBar]
/// trailing 按钮承担（embedded 与独立模式均一致），不嵌入底部导航栏。
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
    return CupertinoTabBar(
      currentIndex: index,
      onTap: (i) => onTap(LedgerTab.values[i]),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_outlined),
          label: loc.flowListTitle,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.pie_chart_outline),
          label: loc.reportTitle,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: loc.accountOverview,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          label: loc.myProfile,
        ),
      ],
    );
  }
}
