import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_app/src/core/utilities/logger.dart' show fatal;
import 'api_state.dart';

export 'api_state.dart';

/// 获取单个资源的 Cubit。
///
/// 用法：
/// ```dart
/// final cubit = GetApiCubit<LedgerServiceV1Book>(
///   loader: () async {
///     final result = await _service.get(id);
///     if (result is Status) throw Exception(result.getMessage);
///     return result as LedgerServiceV1Book;
///   },
/// )..load();
/// ```
class GetApiCubit<T> extends Cubit<ApiResponse<T>> {
  final Future<T> Function() _loader;

  GetApiCubit({required Future<T> Function() loader})
      : _loader = loader,
        super(Initial());

  /// 加载数据。loader 应在遇到业务错误时抛出异常。
  Future<void> load() async {
    emit(Loading());
    try {
      final item = await _loader();
      emit(Success<T>(item));
    } on Exception catch (e) {
      fatal("get item from api exception: $e");
      emit(Error<T>(e.toString()));
    }
  }

  /// 重新加载（等同于 [load]）。
  Future<void> refresh() => load();
}
