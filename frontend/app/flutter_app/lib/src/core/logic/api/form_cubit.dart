import 'package:flutter_bloc/flutter_bloc.dart';

/// 表单加载状态。
enum FormLoadState { initial, loading, loaded, error }

/// 表单 Cubit — 管理初始数据加载的 loading / error 状态。
///
/// 保存（submit）流程继续使用 EasyLoading，与列表页保持一致。
///
/// 用法：
/// ```dart
/// BlocProvider(
///   create: (_) => FormCubit()..loadInitial(() async {
///     await _loadBooks();
///     if (editId != null) await _loadEditTarget();
///   }),
///   child: BlocBuilder<FormCubit, FormLoadState>(
///     builder: (context, state) => switch (state) {
///       FormLoadState.initial || FormLoadState.loading =>
///         const Center(child: CircularProgressIndicator()),
///       FormLoadState.loaded => _buildForm(context),
///       FormLoadState.error => _buildError(context),
///     },
///   ),
/// )
/// ```
class FormCubit extends Cubit<FormLoadState> {
  String errorMessage = '';

  FormCubit() : super(FormLoadState.initial);

  /// 加载初始数据。loader 应在失败时抛出异常。
  Future<void> loadInitial(Future<void> Function() loader) async {
    emit(FormLoadState.loading);
    try {
      await loader();
      if (!isClosed) emit(FormLoadState.loaded);
    } on Exception catch (e) {
      errorMessage = e.toString();
      if (!isClosed) emit(FormLoadState.error);
    }
  }
}
