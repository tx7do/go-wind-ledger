import 'package:flutter/cupertino.dart';

/// iOS 原生下拉刷新容器。
///
/// 替代 MD3 [RefreshIndicator]：顶部出现 iOS 转轮，下拉产生原生回弹。
/// 内容为普通 Widget 列表（分组列表、卡片等），内部转换为 Sliver。
class AppPullRefresh extends StatelessWidget {
  final RefreshCallback onRefresh;

  final List<Widget> children;

  final EdgeInsetsGeometry padding;

  /// 可选滚动控制器（用于滚动分页加载等）
  final ScrollController? controller;

  const AppPullRefresh({
    super.key,
    required this.onRefresh,
    required this.children,
    this.padding = const EdgeInsets.only(bottom: 16),
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: onRefresh),
        SliverPadding(
          padding: padding,
          sliver: SliverList(
            delegate: SliverChildListDelegate(children),
          ),
        ),
      ],
    );
  }
}
