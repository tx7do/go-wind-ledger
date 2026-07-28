import 'package:flutter/material.dart';

/// 统计卡片：展示支出/收入/净额。
///
/// 用于流水列表顶部的汇总信息。金额来自
/// [LedgerServiceV1StatisticsResponse]（字符串形式的小数）。
class StatisticsCard extends StatelessWidget {
  /// 支出金额（字符串，如 "1234.56"）。
  final String expense;

  /// 收入金额（字符串）。
  final String income;

  /// 净额（字符串，可为负）。
  final String net;

  /// 是否正在加载。
  final bool loading;

  const StatisticsCard({
    super.key,
    required this.expense,
    required this.income,
    required this.net,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            _buildCell(
              context,
              label: '支出',
              value: loading ? '--' : expense,
              color: theme.colorScheme.error,
            ),
            _divider(theme),
            _buildCell(
              context,
              label: '收入',
              value: loading ? '--' : income,
              color: Colors.green,
            ),
            _divider(theme),
            _buildCell(
              context,
              label: '净额',
              value: loading ? '--' : net,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatAmount(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Container(
      width: 1,
      height: 32,
      color: theme.colorScheme.outlineVariant.withAlpha(60),
    );
  }

  String _formatAmount(String value) {
    if (value.isEmpty) return '0.00';
    final v = double.tryParse(value);
    if (v == null) return value;
    return v.toStringAsFixed(2);
  }
}
