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

/// 标题栏主题
AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) => AppBarTheme(
  backgroundColor: DarkColor.surfaceColor,
  titleSpacing: kDefaultPadding,
  elevation: 0,
  scrolledUnderElevation: 1,
  titleTextStyle: TextStyle(
    color: DarkColor.onSurface,
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
  ),
  iconTheme: IconThemeData(color: DarkColor.onSurface),
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
TextSelectionThemeData _buildTextSelectionTheme(Color seedColor) =>
    TextSelectionThemeData(
      selectionColor: seedColor.withAlpha((0.4 * 255).round()),
      selectionHandleColor: seedColor,
      cursorColor: DarkColor.cursorColor,
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

/// 顶部搜索栏
final _searchBarTheme = SearchBarThemeData(
  backgroundColor: WidgetStateProperty.all(DarkColor.surfaceColor),
  elevation: WidgetStateProperty.all(0),
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

/// 弹出菜单
PopupMenuThemeData _buildPopupMenuTheme(Color seedColor) => PopupMenuThemeData(
  color: DarkColor.surfaceColor,
  iconColor: seedColor,
  elevation: 4,
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

/// 输入框主题（iOS 风格描边）
InputDecorationTheme _buildInputDecorationTheme(Color seedColor) =>
    InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kInputRadius),
        borderSide: const BorderSide(color: Color(0xFF38383A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kInputRadius),
        borderSide: const BorderSide(color: Color(0xFF38383A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kInputRadius),
        borderSide: BorderSide(color: seedColor),
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
      backgroundColor: DarkColor.surfaceColor,
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
    appBarTheme: _buildAppBarTheme(colorScheme),
    textSelectionTheme: _buildTextSelectionTheme(seedColor),
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
    popupMenuTheme: _buildPopupMenuTheme(seedColor),
    dividerTheme: _dividerTheme,
    scrollbarTheme: _buildScrollbarTheme(seedColor),
    inputDecorationTheme: _buildInputDecorationTheme(seedColor),
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
    ],
  );
}

/// 获取暗黑系主题
/// [seedColor] 种子颜色，用于动态生成配色方案
ThemeData getDarkTheme({Color? seedColor}) {
  final color = seedColor ?? const Color(0xFF3A7CA5);
  return _buildDarkTheme(color);
}
