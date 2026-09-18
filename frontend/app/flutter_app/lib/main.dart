import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsBinding;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:flutter_app/src/app.dart' show LedgerApp;
import 'package:flutter_app/src/init.dart' show init;
import 'package:flutter_app/src/core/themes/index.dart' show AppThemeCubit;
import 'package:flutter_app/src/features/auth/cubit/auth_cubit.dart';

/// 程序入口
Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Web 端启用语义树（无障碍支持 + 自动化测试可定位）
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await init();

  // 初始化完成后移除原生闪屏
  FlutterNativeSplash.remove();

  run();
}

void run() {
  // ignore: missing_provider_scope
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppThemeCubit()),
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: const LedgerApp(),
    ),
  );
}
