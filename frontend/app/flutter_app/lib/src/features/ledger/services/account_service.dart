import 'package:dio/dio.dart' show DioException;
import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        AccountServiceClient,
        LedgerServiceV1Account,
        LedgerServiceV1ListAccountResponse,
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

/// 账户服务
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [AccountServiceClient] 的方法。
class AccountService extends BaseService {
  AccountService() : super(tag: 'AccountService');

  AccountServiceClient get _api => GetIt.instance<ApiClient>().accountService;

  /// 获取账户列表（分页）
  Future<dynamic> list([PaginationQuery? query]) async {
    final q = query ?? const PaginationQuery();
    try {
      return await _api.list(q.toPagingRequest());
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 获取所有账户（不分页）
  Future<dynamic> listAll({bool? includeDisabled}) async {
    try {
      return await _api.listAll(
        LedgerServiceV1ListAllAccountRequest(includeDisabled: includeDisabled),
      );
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 获取单个账户
  Future<dynamic> get(int id) async {
    try {
      return await _api.get(LedgerServiceV1GetAccountRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 创建账户
  Future<dynamic> create(Account data) async {
    try {
      return await _api.create(LedgerServiceV1CreateAccountRequest(data: data));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 更新账户
  Future<dynamic> update(
    int id,
    Account data, {
    String? updateMask,
    bool? allowMissing,
  }) async {
    try {
      return await _api.update(
        LedgerServiceV1UpdateAccountRequest(
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

  /// 删除账户
  Future<dynamic> delete(int id) async {
    try {
      await _api.delete(LedgerServiceV1DeleteAccountRequest(id: id));
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 切换启用/禁用
  Future<dynamic> toggle(int id) async {
    try {
      return await _api.toggle(LedgerServiceV1ToggleAccountRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 余额调整（会创建 ADJUST 流水记录）
  Future<dynamic> adjustBalance({
    required int id,
    required String balance,
    int? bookId,
    int? createTime,
    String? title,
    String? notes,
  }) async {
    try {
      return await _api.adjustBalance(
        LedgerServiceV1AdjustBalanceRequest(
          id: id,
          balance: balance,
          bookId: bookId,
          createTime: createTime,
          title: title,
          notes: notes,
        ),
      );
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }
}
