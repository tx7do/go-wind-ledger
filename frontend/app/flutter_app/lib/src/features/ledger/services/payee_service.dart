import 'package:dio/dio.dart' show DioException;
import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        PayeeServiceClient,
        LedgerServiceV1Payee,
        LedgerServiceV1ListPayeeResponse,
        LedgerServiceV1ListAllPayeeRequest,
        LedgerServiceV1GetPayeeRequest,
        LedgerServiceV1CreatePayeeRequest,
        LedgerServiceV1UpdatePayeeRequest,
        LedgerServiceV1DeletePayeeRequest,
        LedgerServiceV1TogglePayeeRequest;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/services/pagination_query.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

typedef Payee = LedgerServiceV1Payee;
typedef ListPayeeResponse = LedgerServiceV1ListPayeeResponse;

/// 收款人服务
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [PayeeServiceClient] 的方法。
class PayeeService extends BaseService {
  PayeeService() : super(tag: 'PayeeService');

  PayeeServiceClient get _api => GetIt.instance<ApiClient>().payeeService;

  /// 获取收款人列表（分页）
  Future<dynamic> list([PaginationQuery? query]) async {
    final q = query ?? const PaginationQuery();
    try {
      return await _api.list(q.toPagingRequest());
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 获取所有收款人（不分页，可按账本过滤）
  Future<dynamic> listAll({int? bookId}) async {
    try {
      return await _api
          .listAll(LedgerServiceV1ListAllPayeeRequest(bookId: bookId));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 获取单个收款人
  Future<dynamic> get(int id) async {
    try {
      return await _api.get(LedgerServiceV1GetPayeeRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 创建收款人
  Future<dynamic> create(Payee data) async {
    try {
      return await _api.create(LedgerServiceV1CreatePayeeRequest(data: data));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 更新收款人
  Future<dynamic> update(
    int id,
    Payee data, {
    String? updateMask,
    bool? allowMissing,
  }) async {
    try {
      return await _api.update(
        LedgerServiceV1UpdatePayeeRequest(
          id: id,
          data: data,
          updateMask: updateMask,
          allowMissing: allowMissing,
        ),
      );
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 删除收款人
  Future<dynamic> delete(int id) async {
    try {
      await _api.delete(LedgerServiceV1DeletePayeeRequest(id: id));
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 切换启用/禁用
  Future<dynamic> toggle(int id) async {
    try {
      return await _api.toggle(LedgerServiceV1TogglePayeeRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }
}
