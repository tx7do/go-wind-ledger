import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        AccountServiceClient,
        LedgerServiceV1Account,
        LedgerServiceV1AccountAsset,
        LedgerServiceV1ListAccountResponse,
        LedgerServiceV1OverviewResponse,
        LedgerServiceV1OverviewRequest,
        LedgerServiceV1ListAllAccountRequest,
        LedgerServiceV1GetAccountRequest,
        LedgerServiceV1CreateAccountRequest,
        LedgerServiceV1UpdateAccountRequest,
        LedgerServiceV1DeleteAccountRequest,
        LedgerServiceV1ToggleAccountRequest,
        LedgerServiceV1AdjustBalanceRequest;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/services/pagination_query.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

typedef Account = LedgerServiceV1Account;
typedef ListAccountResponse = LedgerServiceV1ListAccountResponse;
typedef OverviewResponse = LedgerServiceV1OverviewResponse;
typedef AccountAsset = LedgerServiceV1AccountAsset;

/// 账户服务
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [AccountServiceClient] 的方法。
class AccountService extends BaseService {
  AccountService() : super(tag: 'AccountService');

  AccountServiceClient get _api => GetIt.instance<ApiClient>().accountService;

  /// 获取账户列表（分页）
  Future<dynamic> list([PaginationQuery? query]) {
    final q = query ?? const PaginationQuery();  return call(() => _api.list(q.toPagingRequest()););
  }

  /// 获取所有账户（不分页）
  Future<dynamic> listAll({bool? includeDisabled}) =>
      call(() => _api.listAll(
        LedgerServiceV1ListAllAccountRequest(includeDisabled: includeDisabled),
      ));

  /// 获取账户概览（总资产/总负债/净资产及明细）
  Future<dynamic> overview() =>
      call(() => _api.overview(LedgerServiceV1OverviewRequest()));

  /// 获取单个账户
  Future<dynamic> get(int id) =>
      call(() => _api.get(LedgerServiceV1GetAccountRequest(id: id)));

  /// 创建账户
  Future<dynamic> create(Account data) =>
      call(() => _api.create(LedgerServiceV1CreateAccountRequest(data: data)));

  /// 更新账户
  Future<dynamic> update(
    int id,
    Account data, {
    String? updateMask,
    bool? allowMissing,
  }) =>
      call(() => _api.update(
        LedgerServiceV1UpdateAccountRequest(
          id: id,
          data: data,
          updateMask: updateMask,
          allowMissing: allowMissing,
        ),
      ));

  /// 删除账户
  Future<dynamic> delete(int id) =>
      call(() async { await _api.delete(LedgerServiceV1DeleteAccountRequest(id: id)); });

  /// 切换启用/禁用
  Future<dynamic> toggle(int id) =>
      call(() => _api.toggle(LedgerServiceV1ToggleAccountRequest(id: id)));

  /// 余额调整（会创建 ADJUST 流水记录）
  Future<dynamic> adjustBalance({
    required int id,
    required String balance,
    int? bookId,
    int? createTime,
    String? title,
    String? notes,
  }) =>
      call(() => _api.adjustBalance(
        LedgerServiceV1AdjustBalanceRequest(
          id: id,
          balance: balance,
          bookId: bookId,
          createTime: createTime,
          title: title,
          notes: notes,
        ),
      ));
}
