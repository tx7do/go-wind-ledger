import 'package:flutter/material.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1FlowType;
import 'package:flutter_app/generated/l10n.dart';

/// 流水类型选择器：支出/收入/转账。
///
/// 使用 MD3 原生 [SegmentedButton]，选中态自动绑定 `primaryContainer`，
/// 颜色、动效、触控热区均随主题联动，无需手写。
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
    final segments = List<ButtonSegment<LedgerServiceV1FlowType>>.generate(
      _types.length,
      (i) => ButtonSegment<LedgerServiceV1FlowType>(
        value: _types[i],
        icon: Icon(_icons[i]),
        label: Text(labels[i]),
      ),
    );

    return SegmentedButton<LedgerServiceV1FlowType>(
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -3, vertical: -3),
      ),
      segments: segments,
      selected: {value},
      onSelectionChanged: (selection) {
        final next = selection.first;
        if (next != value) onChanged(next);
      },
      showSelectedIcon: false,
      multiSelectionEnabled: false,
    );
  }
}
