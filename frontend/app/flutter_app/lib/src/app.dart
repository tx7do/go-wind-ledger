import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_app/generated/l10n.dart' as l10n;

import 'package:flutter_app/src/core/extensions/app_localizations_context.dart';
import 'package:flutter_app/src/core/constants/breakpoints.dart';
import 'package:flutter_app/src/core/themes/fonts.dart';
import 'package:flutter_app/src/core/themes/index.dart' as theme;
import 'package:flutter_app/src/core/utilities/logger.dart' show debug;

import 'app_router/app_router.dart' as pages;

/// 应用程序
class LedgerApp extends StatefulWidget {
  const LedgerApp({super.key});

  @override
  State<LedgerApp> createState() => _LedgerAppState();
}

class _LedgerAppState extends State<LedgerApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Breakpoints.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      builder: (ctx, child) {
        // Web 端：动态将 designSize 设为当前视窗尺寸，使 .w/.h/.sp 始终 1:1
        // 用户缩小浏览器窗口时字体不会跟着缩小，完美符合 Web 阅读习惯
        if (kIsWeb) {
          ScreenUtil.init(
            ctx,
            designSize: Size(
              MediaQuery.of(ctx).size.width,
              MediaQuery.of(ctx).size.height,
            ),
            minTextAdapt: false,
          );
        }
        return _buildMaterialApp(context);
      },
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildMaterialApp(BuildContext context) {
    final delegate = l10n.S.delegate;
    final cubit = context.read<theme.AppThemeCubit>();
    cubit.init();

    // 监听 Cubit 变化，获取最新的 seedColor
    final state = context.watch<theme.AppThemeCubit>().state;
    Color? seedColor;
    if (state is theme.AppThemeInitial) {
      seedColor = state.seedColor;
    } else if (state is theme.AppThemeModified) {
      seedColor = state.seedColor;
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.loc.appName,
      routerConfig: pages.AppRouter.router,
      theme: theme.getLightTheme(seedColor: seedColor),
      darkTheme: theme.getDarkTheme(seedColor: seedColor),
      themeMode: context.watch<theme.AppThemeCubit>().themeMode,
      locale: context.watch<theme.AppThemeCubit>().currentLocale,
      builder: (context, routerChild) {
        // Web 端 Cupertino 组件（按钮/输入框等）内部默认 'CupertinoSystemText'
        // 字体族，CanvasKit 拿不到系统级 CJK 回退会渲染为方块；给全部
        // Cupertino 文本样式注入 pubspec 内置的 Noto Sans SC 作为回退字体族。
        if (kIsWeb) {
          const defaults = CupertinoTextThemeData();
          TextStyle patch(TextStyle s) =>
              s.copyWith(fontFamilyFallback: AppFont.fontFamilyFallback);
          routerChild = CupertinoTheme(
            data: CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                textStyle: patch(defaults.textStyle),
                actionTextStyle: patch(defaults.actionTextStyle),
                actionSmallTextStyle: patch(defaults.actionSmallTextStyle),
                navTitleTextStyle: patch(defaults.navTitleTextStyle),
                navLargeTitleTextStyle: patch(defaults.navLargeTitleTextStyle),
                navActionTextStyle: patch(defaults.navActionTextStyle),
                pickerTextStyle: patch(defaults.pickerTextStyle),
                dateTimePickerTextStyle:
                    patch(defaults.dateTimePickerTextStyle),
                tabLabelTextStyle: patch(defaults.tabLabelTextStyle),
              ),
            ),
            child: routerChild!,
          );
        }
        // EasyLoading 作为路由的外部包装
        final easyLoadingBuilder = EasyLoading.init();
        return easyLoadingBuilder(context, routerChild);
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        delegate,
      ],
      supportedLocales: l10n.S.delegate.supportedLocales,
      localeListResolutionCallback: (locales, supportedLocales) {
        debug('locale list: $locales');
        if (locales == null || locales.isEmpty) {
          return supportedLocales.first;
        }
        for (final locale in locales) {
          // 精确匹配
          if (supportedLocales.contains(locale)) return locale;
          // 语言代码匹配（忽略国家代码差异，如 zh-CN → zh_CN）
          final match = supportedLocales.where(
            (sl) => sl.languageCode == locale.languageCode,
          );
          if (match.isNotEmpty) return match.first;
        }
        return supportedLocales.first;
      },
    );
  }
}
