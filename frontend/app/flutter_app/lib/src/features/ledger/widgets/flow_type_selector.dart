import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1FlowType;
import 'package:flutter_app/generated/l10n.dart';

/// 流水类型选择器：支出/收入/转账。
///
/// 使用 iOS 原生 [CupertinoSlidingSegmentedControl]，选中态滑动过渡，
/// 颜色随主题种子色联动，无需手写。
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

  static const _icons = <IconData>[
    Icons.south_west,
    Icons.north_east,
    Icons.swap_horiz,
  ];

  static List<String> _labels(BuildContext c) => [
        S.of(c).flowFilterExpense,
        S.of(c).flowFilterIncome,
        S.of(c).flowFilterTransfer,
      ];

  @override
  Widget build(BuildContext context) {
    final labels = _labels(context);

    return CupertinoSlidingSegmentedControl<LedgerServiceV1FlowType>(
      groupValue: value,
      onValueChanged: (next) {
        if (next != null && next != value) onChanged(next);
      },
      children: {
        for (var i = 0; i < _types.length; i++)
          _types[i]: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icons[i], size: 16),
                const SizedBox(width: 4),
                Text(labels[i], style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
      },
    );
  }
}
