import 'package:flutter/material.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1AccountType;
import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/themes/semantic_colors.dart';

/// 账户类型标签。
///
/// 以不同颜色的 [Chip] 展示账户类型(资产/活期/信用/负债)。
class AccountTypeTag extends StatelessWidget {
  /// 账户类型。
  final LedgerServiceV1AccountType type;

  const AccountTypeTag({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _descriptor(context, type);
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

  (String, Color) _descriptor(
    BuildContext context,
    LedgerServiceV1AccountType type,
  ) {
    final loc = S.of(context);

    switch (type) {
      case LedgerServiceV1AccountType.accountTypeAsset:
        return (loc.accountTypeAsset, SemanticColors.accountAsset(context));
      case LedgerServiceV1AccountType.accountTypeChecking:
        return (
          loc.accountTypeChecking,
          SemanticColors.accountChecking(context),
        );
      case LedgerServiceV1AccountType.accountTypeCredit:
        return (loc.accountTypeCredit, SemanticColors.accountCredit(context));
      case LedgerServiceV1AccountType.accountTypeDebt:
        return (loc.accountTypeDebt, SemanticColors.accountDebt(context));
      case LedgerServiceV1AccountType.accountTypeUnspecified:
        return (loc.accountTypeOther, SemanticColors.grey(context));
    }
  }
}
