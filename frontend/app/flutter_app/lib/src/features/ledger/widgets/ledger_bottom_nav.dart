import 'package:flutter/material.dart';

/// 记账模块底部导航栏的目标 Tab。
enum LedgerTab { flows, statistics, accounts, mine }

/// 记账模块底部导航栏。
///
/// 4 个普通 Tab（流水/统计/账户/我的）+ 中间凸起的“记一笔”浮动按钮。
/// 使用 [FloatingActionButton] 风格的中间按钮嵌入到 [NavigationBar]。
class LedgerBottomNav extends StatelessWidget {
  /// 当前选中的 Tab。
  final LedgerTab current;

  /// Tab 切换回调。
  final ValueChanged<LedgerTab> onTap;

  /// 点击“记一笔”按钮的回调。
  final VoidCallback onCreate;

  const LedgerBottomNav({
    super.key,
    required this.current,
    required this.onTap,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildItem(
                context,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: '流水',
                tab: LedgerTab.flows,
              ),
              _buildItem(
                context,
                icon: Icons.pie_chart_outline,
                activeIcon: Icons.pie_chart,
                label: '统计',
                tab: LedgerTab.statistics,
              ),
              // 中间“记一笔”浮动按钮
              _buildCreateButton(context),
              _buildItem(
                context,
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet,
                label: '账户',
                tab: LedgerTab.accounts,
              ),
              _buildItem(
                context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: '我的',
                tab: LedgerTab.mine,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required LedgerTab tab,
  }) {
    final theme = Theme.of(context);
    final selected = current == tab;
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(tab),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? activeIcon : icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(80),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onCreate,
            iconSize: 28,
            color: theme.colorScheme.onPrimary,
            icon: const Icon(Icons.add),
            tooltip: '记一笔',
          ),
        ),
      ),
    );
  }
}
