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
  Future<dynamic> list([PaginationQuery? query]) {
    final q = query ?? const PaginationQuery();  return call(() => _api.list(q.toPagingRequest()););
  }

  /// 获取所有收款人（不分页，可按账本过滤）
  Future<dynamic> listAll({int? bookId}) =>
      call(() => _api
          .listAll(LedgerServiceV1ListAllPayeeRequest(bookId: bookId)));

  /// 获取单个收款人
  Future<dynamic> get(int id) =>
      call(() => _api.get(LedgerServiceV1GetPayeeRequest(id: id)));

  /// 创建收款人
  Future<dynamic> create(Payee data) =>
      call(() => _api.create(LedgerServiceV1CreatePayeeRequest(data: data)));

  /// 更新收款人
  Future<dynamic> update(
    int id,
    Payee data, {
    String? updateMask,
    bool? allowMissing,
  }) =>
      call(() => _api.update(
        LedgerServiceV1UpdatePayeeRequest(
          id: id,
          data: data,
          updateMask: updateMask,
          allowMissing: allowMissing,
        ),
      ));

  /// 删除收款人
  Future<dynamic> delete(int id) =>
      call(() async { await _api.delete(LedgerServiceV1DeletePayeeRequest(id: id)); });

  /// 切换启用/禁用
  Future<dynamic> toggle(int id) =>
      call(() => _api.toggle(LedgerServiceV1TogglePayeeRequest(id: id)));
}
