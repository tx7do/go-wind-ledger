import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'const.dart';
import 'fonts.dart';
import 'snackbar_color.dart' show SnackBarColor;
import 'app_theme_extension.dart';

class DarkColor {
  static const Color bgColor = Color.fromRGBO(0, 0, 0, 1.0);
  static const Color surfaceColor = Color.fromRGBO(28, 28, 30, 1.0);
  static const Color onSurface = Color.fromRGBO(255, 255, 255, 1.0);
  static const Color cursorColor = Color(0xFF3A7CA5);
}

ColorScheme _buildDarkColorScheme(Color seedColor) => ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: seedColor,

  /// 主色调，由用户种子色驱动
  primary: seedColor,

  /// 主色调上的文字或图标颜色
  onPrimary: Colors.white,

  /// 主色调的容器背景色
  primaryContainer: Color.alphaBlend(
    seedColor.withAlpha((0.3 * 255).round()),
    DarkColor.surfaceColor,
  ),

  /// 主色调容器上的文字或图标颜色
  onPrimaryContainer: Color.alphaBlend(
    seedColor.withAlpha((0.15 * 255).round()),
    Colors.white,
  ),

  /// secondarySystemGroupedBackground（卡片/行表面）
  surface: DarkColor.surfaceColor,
  surfaceContainer: DarkColor.surfaceColor,

  /// label
  onSurface: DarkColor.onSurface,

  /// 次级容器（保留既有语义色，未列入本次重塑范围）
  secondaryContainer: Color.alphaBlend(
    seedColor.withAlpha((0.15 * 255).round()),
    DarkColor.surfaceColor,
  ),
  onSecondaryContainer: Color.alphaBlend(
    seedColor.withAlpha((0.1 * 255).round()),
    Colors.white,
  ),

  /// iOS systemRed
  error: const Color(0xFFFF453A),
  onError: Colors.white,
);

/// 图标
const _iconTheme = IconThemeData(
  color: DarkColor.onSurface,
);

///
const _snackBarColor = SnackBarColor(
  error: Color.fromRGBO(242, 80, 80, 1),
  info: Color.fromRGBO(26, 181, 148, 1),
  warning: Color.fromRGBO(26, 181, 148, 1),
  success: Color.fromRGBO(26, 181, 148, 1),
);

/// 分割线（iOS separator）
const _dividerTheme = DividerThemeData(
  color: Color(0xFF38383A),
);

/// Scrollbar 主题（中性灰，贴近 iOS 观感）
ScrollbarThemeData _buildScrollbarTheme(Color seedColor) => ScrollbarThemeData(
  thumbColor: WidgetStateProperty.all(const Color(0xFF38383A)),
  radius: const Radius.circular(4),
  thickness: WidgetStateProperty.all(6),
  thumbVisibility: WidgetStateProperty.all(true),
);

/// iOS 风格字阶（标题偏大、正文/标签收敛以兼顾现有布局密度）。
/// 仅设定字号与字重，颜色留空交由 ambient 决定。
TextTheme _buildTextTheme() => TextTheme(
  displayLarge: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700),
  displayMedium: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
  displaySmall: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
  headlineLarge: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
  headlineMedium: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w400),
  headlineSmall: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
  titleLarge: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
  titleMedium: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w400),
  titleSmall: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400),
  bodyLarge: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w400),
  bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
  bodySmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
  labelLarge: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400),
  labelMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
  labelSmall: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w400),
);

///
ThemeData _buildDarkTheme(Color seedColor) {
  final colorScheme = _buildDarkColorScheme(seedColor);
  return ThemeData(
    platform: TargetPlatform.iOS,
    useMaterial3: true,
    fontFamily: kDefaultFontFamily,
    fontFamilyFallback: AppFont.fontFamilyFallback,
    textTheme: _buildTextTheme(),
    colorScheme: colorScheme,
    scaffoldBackgroundColor: DarkColor.bgColor,
    primaryColor: colorScheme.primary,
    iconTheme: _iconTheme,
    dividerTheme: _dividerTheme,
    scrollbarTheme: _buildScrollbarTheme(seedColor),
    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension(snackBarColor: _snackBarColor),
    ],
  );
}

/// 获取暗黑系主题
/// [seedColor] 种子颜色，用于动态生成配色方案
ThemeData getDarkTheme({Color? seedColor}) {
  final color = seedColor ?? const Color(0xFF3A7CA5);
  return _buildDarkTheme(color);
}
