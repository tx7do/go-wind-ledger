import 'package:flutter/material.dart';

/// 语义色定义。
///
/// 为记账业务中的概念(支出/收入/转账/账户类型/成员状态等)提供
/// 统一的颜色映射,替代硬编码的 Colors.red/green/blue/0xFF...。
///
/// 每个方法均接受 [BuildContext],根据当前主题亮度返回适配的颜色,
/// 保证亮暗主题下语义色自然一致。
class SemanticColors {
  SemanticColors._();

  // ─── 流水类型 ────────────────────────────────────────

  /// 支出 — 红色系
  static Color expense(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828);
  }

  /// 收入 — 绿色系
  static Color income(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32);
  }

  /// 转账 — 蓝色系
  static Color transfer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF42A5F5) : const Color(0xFF1565C0);
  }

  /// 余额调整 — 橙色系
  static Color adjust(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFFF8A65) : const Color(0xFFE65100);
  }

  // ─── 账户类型 ────────────────────────────────────────

  /// 资产账户 — 蓝色
  static Color accountAsset(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF42A5F5) : const Color(0xFF1976D2);
  }

  /// 活期账户 — 绿色
  static Color accountChecking(BuildContext context) => income(context);

  /// 信用账户 — 橙色
  static Color accountCredit(BuildContext context) => adjust(context);

  /// 负债账户 — 红色
  static Color accountDebt(BuildContext context) => expense(context);

  // ─── 成员状态 ────────────────────────────────────────

  /// 正常 — 绿色
  static Color memberActive(BuildContext context) => income(context);

  /// 待接受 — 橙色
  static Color memberPending(BuildContext context) => adjust(context);

  /// 已禁用 — 红色
  static Color memberDisabled(BuildContext context) => expense(context);

  // ─── 通用 ───────────────────────────────────────────

  /// 灰色(未知/其他/禁用占位)
  static Color grey(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF9E9E9E) : const Color(0xFF757575);
  }

  /// 全部(筛选器) — 使用主题次要色
  static Color all(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
}
