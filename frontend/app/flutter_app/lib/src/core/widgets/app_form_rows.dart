import 'package:flutter/cupertino.dart';

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/themes/const.dart';

/// 下拉选择项。
class AppSelectOption<T> {
  final T value;

  final String label;

  const AppSelectOption({required this.value, required this.label});
}

/// iOS 风格选择行：左侧标签，右侧当前值 + chevron，点按弹出底部滚轮选择器。
///
/// 需放置在 [CupertinoFormSection] 内（与 [CupertinoFormRow] 同级使用），
/// 分隔线由表单区块统一绘制。
class AppSelectRow<T> extends StatelessWidget {
  final String label;

  final IconData? icon;

  final T value;

  final List<AppSelectOption<T>> options;

  final ValueChanged<T> onChanged;

  const AppSelectRow({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
  });

  String _labelOf(T value) {
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return '';
  }

  Future<void> _pick(BuildContext context) async {
    final loc = S.of(context);
    final initialItem = options.indexWhere((o) => o.value == value);
    // 当前值不在选项中（如尚未选择）时，以滚轮初始高亮项作为默认选中，
    // 保证用户点「确定」即提交高亮项。
    var selected = initialItem >= 0 ? value : (options.isNotEmpty ? options.first.value : value);

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      loc.cancel,
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel.resolveFrom(ctx),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      loc.confirm,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoTheme.of(ctx).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              Container(height: 0.5, color: CupertinoColors.separator.resolveFrom(ctx)),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: initialItem < 0 ? 0 : initialItem,
                  ),
                  itemExtent: 40,
                  useMagnifier: true,
                  magnification: 1.05,
                  onSelectedItemChanged: (i) => selected = options[i].value,
                  children: options
                      .map((o) => Center(child: Text(o.label, style: const TextStyle(fontSize: 18))))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != value) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoFormRow(
      prefix: _RowPrefix(label: label, icon: icon),
      child: GestureDetector(
        onTap: () => _pick(context),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _labelOf(value),
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
            const SizedBox(width: 4),
            const CupertinoListTileChevron(),
          ],
        ),
      ),
    );
  }
}

/// 日期选择行：左侧标签，右侧日期 + chevron，点按弹出底部日历选择器。
///
/// 滚动选择即时回调 [onChanged]；需放置在 [CupertinoFormSection] 内。
class AppDateRow extends StatelessWidget {
  final String label;

  final IconData? icon;

  /// 当前日期；为 null 时显示 [placeholder]
  final DateTime? date;

  /// [date] 为 null 时展示的占位文案
  final String? placeholder;

  final ValueChanged<DateTime> onChanged;

  /// 可选的日期下限（默认 2000 年）
  final DateTime? minimumDate;

  /// 可选的日期上限（默认 2100 年）
  final DateTime? maximumDate;

  const AppDateRow({
    super.key,
    required this.label,
    required this.onChanged,
    this.icon,
    this.date,
    this.placeholder,
    this.minimumDate,
    this.maximumDate,
  });

  Future<void> _pick(BuildContext context) async {
    final loc = S.of(context);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 240,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      loc.confirm,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoTheme.of(ctx).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: date ?? DateTime.now(),
                  minimumDate: minimumDate ?? DateTime(2000),
                  maximumDate: maximumDate ?? DateTime(2100),
                  onDateTimeChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final text = date == null
        ? (placeholder ?? '')
        : '${date!.year}-${two(date!.month)}-${two(date!.day)}';
    return CupertinoFormRow(
      prefix: _RowPrefix(label: label, icon: icon),
      child: GestureDetector(
        onTap: () => _pick(context),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: date == null
                    ? CupertinoColors.tertiaryLabel.resolveFrom(context)
                    : CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
            const SizedBox(width: 4),
            const CupertinoListTileChevron(),
          ],
        ),
      ),
    );
  }
}

/// 开关行：左侧标签，右侧 [CupertinoSwitch]。
///
/// 需放置在 [CupertinoFormSection] 内。
class AppSwitchRow extends StatelessWidget {
  final String label;

  final IconData? icon;

  final bool value;

  final ValueChanged<bool> onChanged;

  const AppSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoFormRow(
      prefix: _RowPrefix(label: label, icon: icon),
      child: CupertinoSwitch(value: value, onChanged: onChanged),
    );
  }
}

/// 表单分区块（iOS insetGrouped 圆角分组容器）。
///
/// [header] 显示在分组上方的小标题（小号灰字）。
class AppFormSection extends StatelessWidget {
  final String? header;

  final String? footer;

  final List<Widget> children;

  const AppFormSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoFormSection.insetGrouped(
      header: header == null ? null : Text(header!),
      footer: footer == null ? null : Text(footer!),
      children: children,
    );
  }
}

/// iOS 圆角卡片容器（白底、[kCardRadius] 圆角、无阴影）。
///
/// 用于统计卡等非表单的分组内容。
class AppCard extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  final EdgeInsetsGeometry padding;

  final Widget child;

  const AppCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(kDefaultPadding),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: child,
    );
  }
}

/// 表单行左侧的前缀（图标 + 标签）。
class _RowPrefix extends StatelessWidget {
  final String label;

  final IconData? icon;

  const _RowPrefix({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: CupertinoTheme.of(context).primaryColor),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );
  }
}
