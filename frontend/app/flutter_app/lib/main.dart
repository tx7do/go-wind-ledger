import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:flutter_app/src/app.dart' show LedgerApp;
import 'package:flutter_app/src/init.dart' show init;
import 'package:flutter_app/src/core/themes/index.dart' show AppThemeCubit;
import 'package:flutter_app/src/features/auth/cubit/auth_cubit.dart';

/// 程序入口
Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 注意：不要在 Web 端强制 ensureSemantics()——语义树会把密码框渲染为
  // 禁用的 DOM 节点并拦截指针事件，导致密码无法输入（回归）。
  // 无障碍按需激活：读屏器接入时引擎会自行弹出启用入口。
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
