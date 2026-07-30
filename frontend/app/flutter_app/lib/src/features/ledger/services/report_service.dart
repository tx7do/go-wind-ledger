import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        ReportServiceClient,
        LedgerServiceV1ReportQueryRequest,
        LedgerServiceV1ReportResponse,
        LedgerServiceV1BalanceReportRequest,
        LedgerServiceV1BalanceReportResponse,
        LedgerServiceV1ChartPoint;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

typedef ReportResponse = LedgerServiceV1ReportResponse;
typedef BalanceReportResponse = LedgerServiceV1BalanceReportResponse;
typedef ChartPoint = LedgerServiceV1ChartPoint;

/// 报表服务
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [ReportServiceClient] 的方法。
class ReportService extends BaseService {
  ReportService() : super(tag: 'ReportService');

  ReportServiceClient get _api => GetIt.instance<ApiClient>().reportService;

  /// 按分类统计支出
  Future<dynamic> expenseCategory({
    int? bookId,
    int? minTime,
    int? maxTime,
    String? title,
    List<int>? categoryIds,
    List<int>? tagIds,
    List<int>? payeeIds,
    int? accountId,
  }) =>
      call(() => _api.expenseCategory(
        LedgerServiceV1ReportQueryRequest(
          bookId: bookId,
          minTime: minTime,
          maxTime: maxTime,
          title: title,
          categoryIds: categoryIds,
          tagIds: tagIds,
          payeeIds: payeeIds,
          accountId: accountId,
        ),
      ));

  /// 按分类统计收入
  Future<dynamic> incomeCategory({
    int? bookId,
    int? minTime,
    int? maxTime,
    String? title,
    List<int>? categoryIds,
    List<int>? tagIds,
    List<int>? payeeIds,
    int? accountId,
  }) =>
      call(() => _api.incomeCategory(
        LedgerServiceV1ReportQueryRequest(
          bookId: bookId,
          minTime: minTime,
          maxTime: maxTime,
          title: title,
          categoryIds: categoryIds,
          tagIds: tagIds,
          payeeIds: payeeIds,
          accountId: accountId,
        ),
      ));

  /// 按标签统计支出
  Future<dynamic> expenseTag({
    int? bookId,
    int? minTime,
    int? maxTime,
    String? title,
    List<int>? categoryIds,
    List<int>? tagIds,
    List<int>? payeeIds,
    int? accountId,
  }) =>
      call(() => _api.expenseTag(
        LedgerServiceV1ReportQueryRequest(
          bookId: bookId,
          minTime: minTime,
          maxTime: maxTime,
          title: title,
          categoryIds: categoryIds,
          tagIds: tagIds,
          payeeIds: payeeIds,
          accountId: accountId,
        ),
      ));

  /// 按标签统计收入
  Future<dynamic> incomeTag({
    int? bookId,
    int? minTime,
    int? maxTime,
    String? title,
    List<int>? categoryIds,
    List<int>? tagIds,
    List<int>? payeeIds,
    int? accountId,
  }) =>
      call(() => _api.incomeTag(
        LedgerServiceV1ReportQueryRequest(
          bookId: bookId,
          minTime: minTime,
          maxTime: maxTime,
          title: title,
          categoryIds: categoryIds,
          tagIds: tagIds,
          payeeIds: payeeIds,
          accountId: accountId,
        ),
      ));

  /// 按收款人统计支出
  Future<dynamic> expensePayee({
    int? bookId,
    int? minTime,
    int? maxTime,
    String? title,
    List<int>? categoryIds,
    List<int>? tagIds,
    List<int>? payeeIds,
    int? accountId,
  }) =>
      call(() => _api.expensePayee(
        LedgerServiceV1ReportQueryRequest(
          bookId: bookId,
          minTime: minTime,
          maxTime: maxTime,
          title: title,
          categoryIds: categoryIds,
          tagIds: tagIds,
          payeeIds: payeeIds,
          accountId: accountId,
        ),
      ));

  /// 按收款人统计收入
  Future<dynamic> incomePayee({
    int? bookId,
    int? minTime,
    int? maxTime,
    String? title,
    List<int>? categoryIds,
    List<int>? tagIds,
    List<int>? payeeIds,
    int? accountId,
  }) =>
      call(() => _api.incomePayee(
        LedgerServiceV1ReportQueryRequest(
          bookId: bookId,
          minTime: minTime,
          maxTime: maxTime,
          title: title,
          categoryIds: categoryIds,
          tagIds: tagIds,
          payeeIds: payeeIds,
          accountId: accountId,
        ),
      ));

  /// 资产负债报表
  Future<dynamic> balance({int? bookId}) =>
      call(() => _api
          .balance(LedgerServiceV1BalanceReportRequest(bookId: bookId)));
}
