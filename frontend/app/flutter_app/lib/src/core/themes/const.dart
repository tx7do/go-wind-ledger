import 'package:flutter_app/src/core/utilities/platform.dart';

const double kDefaultPadding = 16.0;

const String kDefaultFontFamily = 'Noto Sans SC';

const double kMainSpace = 10.0;

double kMainLineWidth(bool isDarkMode) => isDarkMode ? 0.5 : 1.0;

// ─── 统一圆角常量 ──────────────────────────────────────

/// 卡片圆角
const double kCardRadius = 14.0;

/// 输入框圆角
const double kInputRadius = 12.0;

/// 按钮圆角
const double kButtonRadius = 12.0;

/// 标签/徽章圆角
const double kTagRadius = 6.0;

// ─── 统一间距常量 ──────────────────────────────────────

/// 卡片外边距(horizontal)
const double kCardMarginH = 12.0;

/// 卡片外边距(vertical)
const double kCardMarginV = 4.0;

/// 列表项外边距(horizontal)
const double kListMarginH = 12.0;

/// 列表项外边距(vertical)
const double kListMarginV = 4.0;

/// 获取默认的字体
String getDefaultFontFamily() {
  if (PlatformUtils.isApple) {
    return 'PingFang SC';
  } else if (PlatformUtils.isAndroid) {
    return 'Roboto';
  } else if (PlatformUtils.isWindows) {
    return 'Microsoft YaHei';
  } else if (PlatformUtils.isLinux) {
    return 'Roboto';
  } else if (PlatformUtils.isWeb) {
    return 'Noto Sans SC';
  } else {
    return kDefaultFontFamily;
  }
}
