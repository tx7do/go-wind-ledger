import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_app/src/core/utilities/logger.dart' show fatal;
import 'api_state.dart';

export 'api_state.dart';

/// 列表资源 Cubit。
///
/// 封装 loading / success / error 三态。
/// loader 应在遇到业务错误（[Status]）时抛出异常，
/// 成功时返回 `List<T>`。
///
/// 用法：
/// ```dart
/// final cubit = ListApiCubit<LedgerServiceV1Book>(
///   loader: () async {
///     final result = await _service.listAll();
///     if (result is Status) throw Exception(result.getMessage);
///     return (result as LedgerServiceV1ListBookResponse).items ?? [];
///   },
/// )..load();
/// ```
class ListApiCubit<T> extends Cubit<ApiResponse<List<T>>> {
  final Future<List<T>> Function() _loader;

  ListApiCubit({required Future<List<T>> Function() loader})
      : _loader = loader,
        super(Initial());

  /// 加载数据。
  Future<void> load() async {
    emit(Loading());
    try {
      final items = await _loader();
      emit(Success<List<T>>(items));
    } on Exception catch (e) {
      fatal("list items from api exception: $e");
      emit(Error<List<T>>(e.toString()));
    }
  }

  /// 重新加载（等同于 [load]）。
  Future<void> refresh() => load();
}
