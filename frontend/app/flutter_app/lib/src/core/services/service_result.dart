import 'package:flutter_app/src/core/transport/http/status.dart';

/// 服务调用结果。
///
/// 消除 [Future<dynamic>] 返回值和手动的 `if (result is Xxx)` 判型。
///
/// 用法：
/// ```dart
/// final result = await bookService.listAll();
/// switch (result) {
///   case Success(:final data): // data 类型为 T，编译器自动推导
///   case Failure(:final status): // 错误信息
/// }
/// ```
sealed class ServiceResult<T> {
  const ServiceResult();
}

/// 成功结果，携带强类型 [data]。
class Success<T> extends ServiceResult<T> {
  final T data;
  const Success(this.data);
}

/// 失败结果，携带 [Status] 错误对象。
class Failure<T> extends ServiceResult<T> {
  final Status status;
  const Failure(this.status);
}
