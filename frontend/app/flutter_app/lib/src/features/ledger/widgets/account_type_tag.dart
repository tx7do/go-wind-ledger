import 'package:flutter/material.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1AccountType;

/// 账户类型标签。
///
/// 以不同颜色的 [Chip] 展示账户类型（资产/活期/信用/负债）。
class AccountTypeTag extends StatelessWidget {
  /// 账户类型。
  final LedgerServiceV1AccountType type;

  const AccountTypeTag({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _descriptor(type);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(120), width: 0.8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }

  (String, Color) _descriptor(LedgerServiceV1AccountType type) {
    switch (type) {
      case LedgerServiceV1AccountType.accountTypeAsset:
        return ('资产', const Color(0xFF1976D2));
      case LedgerServiceV1AccountType.accountTypeChecking:
        return ('活期', const Color(0xFF2E7D32));
      case LedgerServiceV1AccountType.accountTypeCredit:
        return ('信用', const Color(0xFFE65100));
      case LedgerServiceV1AccountType.accountTypeDebt:
        return ('负债', const Color(0xFFC62828));
      case LedgerServiceV1AccountType.accountTypeUnspecified:
        return ('其他', Colors.grey);
    }
  }
}
