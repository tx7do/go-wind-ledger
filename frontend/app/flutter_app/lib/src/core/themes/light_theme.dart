import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'const.dart';
import 'fonts.dart';
import 'snackbar_color.dart' show SnackBarColor;
import 'app_theme_extension.dart';

/// 默认主题色
const Color kDefaultSeedColor = Color(0xFF3A7CA5);

class LightColor {
  /// systemGroupedBackground
  static const Color bgColor = Color.fromRGBO(242, 242, 247, 1.0);
  static const Color onPrimaryColor = Color.fromRGBO(255, 255, 255, 1.0);
  static const Color cursorColor = Color(0xFF3A7CA5);
}

ColorScheme _buildLightColorScheme(Color seedColor) => ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: seedColor,

  /// 主色调，由用户种子色驱动（与暗色端一致）
  primary: seedColor,

  /// 主色调上的文字或图标颜色
  onPrimary: LightColor.onPrimaryColor,

  /// 主色调的容器背景色（种子色低 alpha 叠白）
  primaryContainer: Color.alphaBlend(
    seedColor.withAlpha((0.3 * 255).round()),
    const Color(0xFFFFFFFF),
  ),

  /// 主色调容器上的文字或图标颜色
  onPrimaryContainer: Color.alphaBlend(
    seedColor.withAlpha((0.15 * 255).round()),
    const Color(0xFFFFFFFF),
  ),

  /// secondarySystemGroupedBackground（卡片/行表面）
  surface: const Color(0xFFFFFFFF),
  surfaceContainer: const Color(0xFFFFFFFF),

  /// label
  onSurface: const Color.fromRGBO(0, 0, 0, 1.0),

  /// 次级容器（保留既有语义色，未列入本次重塑范围）
  secondaryContainer: const Color.fromRGBO(255, 237, 220, 1.0),
  onSecondaryContainer: const Color.fromRGBO(120, 60, 10, 1.0),

  /// iOS systemRed
  error: const Color(0xFFFF3B30),
  onError: const Color(0xFFFFFFFF),
);

/// 标题栏主题
final _appBarTheme = AppBarTheme(
  backgroundColor: const Color(0xFFFFFFFF),
  titleSpacing: kDefaultPadding,
  elevation: 0,
  scrolledUnderElevation: 1,
  titleTextStyle: TextStyle(
    color: const Color.fromRGBO(0, 0, 0, 1.0),
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
  ),
  iconTheme: const IconThemeData(color: Color.fromRGBO(0, 0, 0, 1.0)),
);

/// 主操作按钮样式（Elevated / Filled 共用）
ButtonStyle _primaryButtonStyle(ColorScheme cs) => ButtonStyle(
  elevation: WidgetStateProperty.all(0),
  backgroundColor: WidgetStateProperty.all(cs.primary),
  foregroundColor: WidgetStateProperty.all(cs.onPrimary),
  textStyle: WidgetStateProperty.all(
    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
  ),
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(kButtonRadius)),
  ),
);

/// 次级文本按钮样式
ButtonStyle _textButtonStyle(ColorScheme cs) => ButtonStyle(
  elevation: WidgetStateProperty.all(0),
  backgroundColor: WidgetStateProperty.all(Colors.transparent),
  foregroundColor: WidgetStateProperty.all(cs.primary),
  textStyle: WidgetStateProperty.all(
    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
  ),
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(kButtonRadius)),
  ),
);

/// 描边按钮样式
ButtonStyle _outlinedButtonStyle(ColorScheme cs) => ButtonStyle(
  elevation: WidgetStateProperty.all(0),
  backgroundColor: WidgetStateProperty.all(Colors.transparent),
  foregroundColor: WidgetStateProperty.all(cs.primary),
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
      side: BorderSide(color: cs.primary),
    ),
  ),
);

/// 文本选择
const _textSelectionThemeData = TextSelectionThemeData(
  selectionColor: Color.fromARGB(255, 111, 181, 210),
  selectionHandleColor: Color.fromARGB(255, 111, 181, 210),
  cursorColor: LightColor.cursorColor,
);

/// 图标
const _iconTheme = IconThemeData(color: Color.fromRGBO(0, 0, 0, 1.0));

///
const _snackBarColor = SnackBarColor(
  error: Color.fromRGBO(211, 45, 81, 1),
  info: Color.fromRGBO(26, 181, 148, 1),
  warning: Color.fromRGBO(26, 181, 148, 1),
  success: Color.fromRGBO(26, 181, 148, 1),
);

/// 顶部搜索栏
final _searchBarTheme = SearchBarThemeData(
  backgroundColor: WidgetStateProperty.all(Colors.white),
  elevation: WidgetStateProperty.all(0),
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

/// 弹出菜单
PopupMenuThemeData _buildPopupMenuTheme(ColorScheme cs) => PopupMenuThemeData(
  color: const Color(0xFFFFFFFF),
  iconColor: cs.primary,
  elevation: 4,
);

/// 分割线（iOS separator）
const _dividerTheme = DividerThemeData(color: Color(0xFFC6C6C8));

/// Scrollbar 主题（中性灰，贴近 iOS 观感）
ScrollbarThemeData _buildScrollbarTheme() => ScrollbarThemeData(
  thumbColor: WidgetStateProperty.all(const Color(0xFFC6C6C8)),
  radius: const Radius.circular(4),
  thickness: WidgetStateProperty.all(6),
  thumbVisibility: WidgetStateProperty.all(true),
);

/// 输入框主题（iOS 风格描边）
InputDecorationTheme _buildInputDecorationTheme(ColorScheme cs) =>
    InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kInputRadius),
        borderSide: const BorderSide(color: Color(0xFFC6C6C8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kInputRadius),
        borderSide: const BorderSide(color: Color(0xFFC6C6C8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kInputRadius),
        borderSide: BorderSide(color: cs.primary),
      ),
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

/// 底部 Tab 栏主题（无 M3 选中胶囊，选中=种子色，未选中=中性灰）
NavigationBarThemeData _buildNavigationBarTheme(ColorScheme cs) =>
    NavigationBarThemeData(
      indicatorColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          );
        }
        return TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF8E8E93),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(size: 24.sp, color: cs.primary);
        }
        return const IconThemeData(size: 24.0, color: Color(0xFF8E8E93));
      }),
    );

///
ThemeData _buildLightTheme(Color seedColor) {
  final colorScheme = _buildLightColorScheme(seedColor);
  return ThemeData(
    platform: TargetPlatform.iOS,
    useMaterial3: true,
    fontFamily: kDefaultFontFamily,
    fontFamilyFallback: AppFont.fontFamilyFallback,
    textTheme: _buildTextTheme(),
    colorScheme: colorScheme,
    scaffoldBackgroundColor: LightColor.bgColor,
    primaryColor: colorScheme.primary,
    appBarTheme: _appBarTheme,
    textSelectionTheme: _textSelectionThemeData,
    elevatedButtonTheme:
        ElevatedButtonThemeData(style: _primaryButtonStyle(colorScheme)),
    filledButtonTheme:
        FilledButtonThemeData(style: _primaryButtonStyle(colorScheme)),
    textButtonTheme:
        TextButtonThemeData(style: _textButtonStyle(colorScheme)),
    outlinedButtonTheme:
        OutlinedButtonThemeData(style: _outlinedButtonStyle(colorScheme)),
    iconTheme: _iconTheme,
    searchBarTheme: _searchBarTheme,
    popupMenuTheme: _buildPopupMenuTheme(colorScheme),
    dividerTheme: _dividerTheme,
    scrollbarTheme: _buildScrollbarTheme(),
    inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kCardRadius)),
      ),
    ),
    chipTheme: const ChipThemeData(
      side: BorderSide.none,
    ),
    navigationBarTheme: _buildNavigationBarTheme(colorScheme),
    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension(snackBarColor: _snackBarColor),
    ]);
}

/// 获取光亮系主题
/// [seedColor] 种子颜色，用于动态生成配色方案
ThemeData getLightTheme({Color? seedColor}) {
  final color = seedColor ?? kDefaultSeedColor;
  return _buildLightTheme(color);
}
