import 'package:flutter/material.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1FlowType;

/// 流水类型选择器：支出/收入/转账。
///
/// 以 [ToggleButtons] 形式展示，用于记账表单顶部切换类型。
class FlowTypeSelector extends StatelessWidget {
  /// 当前选中的流水类型。
  final LedgerServiceV1FlowType value;

  /// 类型切换回调。
  final ValueChanged<LedgerServiceV1FlowType> onChanged;

  const FlowTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _types = <LedgerServiceV1FlowType>[
    LedgerServiceV1FlowType.flowTypeExpense,
    LedgerServiceV1FlowType.flowTypeIncome,
    LedgerServiceV1FlowType.flowTypeTransfer,
  ];

  static const _labels = <String>['支出', '收入', '转账'];
  static const _icons = <IconData>[
    Icons.south_west,
    Icons.north_east,
    Icons.swap_horiz,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_types.length, (i) {
          final type = _types[i];
          final selected = type == value;
          final color = selected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant;
          final bg = selected ? theme.colorScheme.primary : Colors.transparent;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: i == 0 || i == _types.length - 1 ? 0 : 4,
              ),
              child: Material(
                color: bg,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onChanged(type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_icons[i], size: 18, color: color),
                        const SizedBox(width: 6),
                        Text(
                          _labels[i],
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: color,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
