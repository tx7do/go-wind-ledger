import 'package:flutter/cupertino.dart';

import 'package:flutter_app/src/core/themes/const.dart';

/// 主操作按钮（iOS 填充式）。
///
/// 用于页面主 CTA（保存/登录等）；[destructive] 为 true 时呈红色危险样式。
/// 禁用态由 [CupertinoButton] 自动降透明度。
class AppFilledButton extends StatelessWidget {
  final String label;

  final VoidCallback? onPressed;

  final IconData? icon;

  /// 自定义填充色（默认取主题种子色）
  final Color? color;

  /// 危险操作（删除/退出登录），红色填充
  final bool destructive;

  /// 是否撑满可用宽度
  final bool expanded;

  const AppFilledButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.destructive = false,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = destructive
        ? CupertinoColors.systemRed.resolveFrom(context)
        : (color ?? CupertinoTheme.of(context).primaryColor);
    final foreground = CupertinoColors.white;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
      ],
    );
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: bg,
      borderRadius: BorderRadius.circular(kButtonRadius),
      onPressed: onPressed,
      child: expanded ? SizedBox(width: double.infinity, child: content) : content,
    );
  }
}

/// 次级/幽灵按钮（无边框透明底）。
///
/// 用于错误重试、次要入口等；[destructive] 时文字为红色。
class AppGhostButton extends StatelessWidget {
  final String label;

  final VoidCallback? onPressed;

  final IconData? icon;

  final bool destructive;

  const AppGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? CupertinoColors.systemRed.resolveFrom(context)
        : CupertinoTheme.of(context).primaryColor;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

/// 导航栏图标按钮（无内边距，适配 [CupertinoNavigationBar] trailing）。
class AppNavIconButton extends StatelessWidget {
  final IconData icon;

  final VoidCallback? onPressed;

  final Color? color;

  const AppNavIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      // iOS HIG：最小可点区域 44x44，避免行内按钮误触相邻手势
      minimumSize: const Size(44, 44),
      onPressed: onPressed,
      child: Icon(icon, size: 22, color: color ?? CupertinoTheme.of(context).primaryColor),
    );
  }
}
