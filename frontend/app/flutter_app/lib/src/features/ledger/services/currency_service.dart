import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        CurrencyServiceClient,
        LedgerServiceV1Currency,
        LedgerServiceV1ListCurrencyResponse,
        LedgerServiceV1ListAllCurrencyRequest,
        LedgerServiceV1RefreshCurrencyRequest,
        LedgerServiceV1ConvertCurrencyRequest,
        LedgerServiceV1ConvertCurrencyResponse;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/services/pagination_query.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

typedef Currency = LedgerServiceV1Currency;
typedef ListCurrencyResponse = LedgerServiceV1ListCurrencyResponse;
typedef ConvertCurrencyResponse = LedgerServiceV1ConvertCurrencyResponse;

/// 币种服务
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [CurrencyServiceClient] 的方法。
class CurrencyService extends BaseService {
  CurrencyService() : super(tag: 'CurrencyService');

  CurrencyServiceClient get _api =>
      GetIt.instance<ApiClient>().currencyService;

  /// 获取所有币种（不分页）
  Future<dynamic> listAll() =>
      call(() => _api.listAll(LedgerServiceV1ListAllCurrencyRequest()));

  /// 获取币种列表（分页）
  Future<dynamic> list([PaginationQuery? query]) async {
    final q = query ?? const PaginationQuery();
    return call(() =>
      _api.list(q.toPagingRequest()));
  }

  /// 刷新汇率
  Future<dynamic> refresh() =>
      call(() => _api.refresh(LedgerServiceV1RefreshCurrencyRequest()));

  /// 币种转换
  Future<dynamic> convert({
    required String amount,
    required String from,
    required String to,
  }) =>
      call(() => _api.convert(
        LedgerServiceV1ConvertCurrencyRequest(
          amount: amount,
          from: from,
          to: to,
        ),
      ));
}
