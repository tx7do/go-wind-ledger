import 'package:flutter/material.dart';

/// Web 端壳层布局（简化版，不依赖 CMS 导航）
class WebShellLayout extends StatelessWidget {
  final Widget child;

  const WebShellLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
