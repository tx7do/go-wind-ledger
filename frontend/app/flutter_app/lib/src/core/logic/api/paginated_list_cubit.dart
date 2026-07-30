import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_app/src/core/utilities/logger.dart' show fatal;

/// 分页列表状态。
sealed class PaginatedListState<T> extends Equatable {
  const PaginatedListState();
}

/// 初始状态。
final class PaginatedInitial<T> extends PaginatedListState<T> {
  @override
  List<Object> get props => [];
}

/// 首次加载中。
final class PaginatedLoading<T> extends PaginatedListState<T> {
  @override
  List<Object> get props => [];
}

/// 加载成功。
final class PaginatedLoaded<T> extends PaginatedListState<T> {
  final List<T> items;
  final bool hasMore;
  final bool loadingMore;

  const PaginatedLoaded({
    required this.items,
    required this.hasMore,
    this.loadingMore = false,
  });

  @override
  List<Object> get props => [items, hasMore, loadingMore];
}

/// 加载失败。
final class PaginatedError<T> extends PaginatedListState<T> {
  final String message;

  const PaginatedError(this.message);

  @override
  List<Object> get props => [message];
}

/// 分页列表 Cubit。
///
/// 支持首次加载、加载更多、刷新。
/// [pageLoader] 接受页码，返回该页数据列表。
/// [pageSize] 用于判断是否还有更多。
///
/// 用法：
/// ```dart
/// final cubit = PaginatedListCubit<LedgerServiceV1BalanceFlow>(
///   pageLoader: (page) async {
///     final result = await _service.list(PaginationQuery(page: page, pageSize: 20));
///     if (result is Status) throw Exception(result.getMessage);
///     final r = result as LedgerServiceV1ListBalanceFlowResponse;
///     return (items: r.items ?? [], total: r.total ?? 0);
///   },
///   pageSize: 20,
/// )..load();
/// ```
class PaginatedListCubit<T> extends Cubit<PaginatedListState<T>> {
  final Future<({List<T> items, int total})> Function(int page) _pageLoader;
  final int _pageSize;

  int _page = 0;
  final List<T> _items = [];

  PaginatedListCubit({
    required Future<({List<T> items, int total})> Function(int page) pageLoader,
    int pageSize = 20,
  })  : _pageLoader = pageLoader,
        _pageSize = pageSize,
        super(PaginatedInitial());

  /// 首页加载。
  Future<void> load() async {
    emit(PaginatedLoading());
    try {
      _page = 1;
      _items.clear();
      final result = await _pageLoader(_page);
      _items.addAll(result.items);
      emit(PaginatedLoaded<T>(
        items: List.unmodifiable(_items),
        hasMore: _items.length < result.total,
      ));
    } on Exception catch (e) {
      fatal("paginated list load exception: $e");
      emit(PaginatedError<T>(e.toString()));
    }
  }

  /// 加载下一页。
  Future<void> loadMore() async {
    final current = state;
    if (current is! PaginatedLoaded<T>) return;
    if (current.loadingMore || !current.hasMore) return;

    emit(PaginatedLoaded<T>(
      items: current.items,
      hasMore: current.hasMore,
      loadingMore: true,
    ));

    try {
      final nextPage = _page + 1;
      final result = await _pageLoader(nextPage);
      _items.addAll(result.items);
      _page = nextPage;
      emit(PaginatedLoaded<T>(
        items: List.unmodifiable(_items),
        hasMore: _items.length < result.total,
      ));
    } on Exception catch (e) {
      // 加载更多失败时保留已有数据，回退到已加载状态
      emit(PaginatedLoaded<T>(
        items: current.items,
        hasMore: current.hasMore,
      ));
    }
  }

  /// 刷新（重新首页加载）。
  Future<void> refresh() => load();
}
