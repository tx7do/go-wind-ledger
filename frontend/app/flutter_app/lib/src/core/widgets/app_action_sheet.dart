import 'package:flutter/cupertino.dart';

import 'package:flutter_app/generated/l10n.dart';

/// 底部操作面板项。
class AppActionSheetItem<T> {
  final T value;

  final String label;

  final IconData? icon;

  /// 危险操作（红色文字，如删除/停用）
  final bool destructive;

  const AppActionSheetItem({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
  });
}

/// 弹出 iOS 底部操作面板（替代 MD3 [PopupMenuButton]）。
///
/// 返回被选项的 [AppActionSheetItem.value]；用户点取消或遮罩关闭时返回 null。
/// 面板底部自带「取消」按钮，符合微信/支付宝的行内操作交互习惯。
Future<T?> showAppActionSheet<T>(
  BuildContext context, {
  String? title,
  String? message,
  required List<AppActionSheetItem<T>> actions,
}) {
  final loc = S.of(context);
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (ctx) => CupertinoActionSheet(
      title: title == null ? null : Text(title),
      message: message == null ? null : Text(message),
      actions: actions
          .map(
            (a) => CupertinoActionSheetAction(
              isDestructiveAction: a.destructive,
              onPressed: () => Navigator.of(ctx).pop(a.value),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (a.icon != null) ...[
                    Icon(a.icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(a.label),
                ],
              ),
            ),
          )
          .toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(ctx).pop(),
        child: Text(loc.cancel),
      ),
    ),
  );
}
