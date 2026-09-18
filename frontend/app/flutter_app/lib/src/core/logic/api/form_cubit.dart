import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_app/src/core/transport/http/status.dart';

/// 表单状态。
enum FormLoadState { initial, loading, loaded, saving, error }

/// 表单 Cubit — 管理加载 / 保存的 loading / error 状态。
///
/// ```dart
/// // 初始化加载
/// formCubit.loadInitial(() async { ... });
///
/// // 保存（自动处理 Status 错误 + EasyLoading）
/// final success = await formCubit.save(() => _service.create(data));
/// if (success && mounted) {
///   EasyLoading.showSuccess(loc.saveSuccess);
///   context.pop();
/// }
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

  /// 保存表单。saver 返回原始结果（成功返回数据，失败返回 Status）。
  /// 返回 true 表示保存成功。
  ///
  /// 保存失败时状态回到 [FormLoadState.loaded]（保留表单内容供用户修正），
  /// 错误信息记录在 [errorMessage]，由页面以 toast 形式提示；
  /// 不进入 error 态——error 态仅用于「初始数据加载失败」的整页替换。
  Future<bool> save(Future<dynamic> Function() saver) async {
    emit(FormLoadState.saving);
    try {
      final result = await saver();
      if (result is Status) {
        errorMessage = result.getMessage;
        if (!isClosed) emit(FormLoadState.loaded);
        return false;
      }
      if (!isClosed) emit(FormLoadState.loaded);
      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      if (!isClosed) emit(FormLoadState.loaded);
      return false;
    }
  }
}
