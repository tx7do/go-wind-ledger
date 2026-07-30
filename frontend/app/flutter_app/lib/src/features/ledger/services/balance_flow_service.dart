import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        BalanceFlowServiceClient,
        LedgerServiceV1BalanceFlow,
        LedgerServiceV1ListBalanceFlowResponse,
        LedgerServiceV1GetBalanceFlowRequest,
        LedgerServiceV1CreateBalanceFlowRequest,
        LedgerServiceV1UpdateBalanceFlowRequest,
        LedgerServiceV1DeleteBalanceFlowRequest,
        LedgerServiceV1ConfirmBalanceFlowRequest,
        LedgerServiceV1StatisticsRequest,
        LedgerServiceV1StatisticsResponse,
        LedgerServiceV1FlowType;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/services/pagination_query.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

typedef BalanceFlow = LedgerServiceV1BalanceFlow;
typedef ListBalanceFlowResponse = LedgerServiceV1ListBalanceFlowResponse;
typedef StatisticsResponse = LedgerServiceV1StatisticsResponse;

/// 流水服务
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [BalanceFlowServiceClient] 的方法。
class BalanceFlowService extends BaseService {
  BalanceFlowService() : super(tag: 'BalanceFlowService');

  BalanceFlowServiceClient get _api =>
      GetIt.instance<ApiClient>().balanceFlowService;

  /// 获取流水列表（分页）
  Future<dynamic> list([PaginationQuery? query]) {
    final q = query ?? const PaginationQuery();  return call(() => _api.list(q.toPagingRequest()););
  }

  /// 获取单个流水
  Future<dynamic> get(int id) =>
      call(() => _api.get(LedgerServiceV1GetBalanceFlowRequest(id: id)));

  /// 创建流水
  Future<dynamic> create(BalanceFlow data) =>
      call(() => _api
          .create(LedgerServiceV1CreateBalanceFlowRequest(data: data)));

  /// 更新流水
  Future<dynamic> update(
    int id,
    BalanceFlow data, {
    String? updateMask,
    bool? allowMissing,
  }) =>
      call(() => _api.update(
        LedgerServiceV1UpdateBalanceFlowRequest(
          id: id,
          data: data,
          updateMask: updateMask,
          allowMissing: allowMissing,
        ),
      ));

  /// 删除流水
  Future<dynamic> delete(int id) =>
      call(() async { await _api.delete(LedgerServiceV1DeleteBalanceFlowRequest(id: id)); });

  /// 确认流水（更新账户余额）
  Future<dynamic> confirm(int id) =>
      call(() => _api
          .confirm(LedgerServiceV1ConfirmBalanceFlowRequest(id: id)));

  /// 统计（支出/收入/净额）
  Future<dynamic> statistics({
    int? bookId,
    LedgerServiceV1FlowType? type,
    String? title,
    String? minAmount,
    String? maxAmount,
    int? minTime,
    int? maxTime,
    int? accountId,
    List<int>? categoryIds,
    List<int>? tagIds,
    bool? confirm,
    bool? include,
  }) =>
      call(() => _api.statistics(
        LedgerServiceV1StatisticsRequest(
          bookId: bookId,
          type: type,
          title: title,
          minAmount: minAmount,
          maxAmount: maxAmount,
          minTime: minTime,
          maxTime: maxTime,
          accountId: accountId,
          categoryIds: categoryIds,
          tagIds: tagIds,
          confirm: confirm,
          include: include,
        ),
      ));
}
