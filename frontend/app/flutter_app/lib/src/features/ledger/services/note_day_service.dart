import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        NoteDayServiceClient,
        LedgerServiceV1NoteDay,
        LedgerServiceV1ListNoteDayResponse,
        LedgerServiceV1GetNoteDayRequest,
        LedgerServiceV1CreateNoteDayRequest,
        LedgerServiceV1UpdateNoteDayRequest,
        LedgerServiceV1DeleteNoteDayRequest,
        LedgerServiceV1RunNoteDayRequest,
        LedgerServiceV1RecallNoteDayRequest;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/services/pagination_query.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

typedef NoteDay = LedgerServiceV1NoteDay;
typedef ListNoteDayResponse = LedgerServiceV1ListNoteDayResponse;

/// 定期提醒服务
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [NoteDayServiceClient] 的方法。
class NoteDayService extends BaseService {
  NoteDayService() : super(tag: 'NoteDayService');

  NoteDayServiceClient get _api => GetIt.instance<ApiClient>().noteDayService;

  /// 获取提醒列表（分页）
  Future<dynamic> list([PaginationQuery? query]) {
    final q = query ?? const PaginationQuery();  return call(() => _api.list(q.toPagingRequest()););
  }

  /// 获取单个提醒
  Future<dynamic> get(int id) =>
      call(() => _api.get(LedgerServiceV1GetNoteDayRequest(id: id)));

  /// 创建提醒
  Future<dynamic> create(NoteDay data) =>
      call(() => _api.create(LedgerServiceV1CreateNoteDayRequest(data: data)));

  /// 更新提醒
  Future<dynamic> update(
    int id,
    NoteDay data, {
    String? updateMask,
    bool? allowMissing,
  }) =>
      call(() => _api.update(
        LedgerServiceV1UpdateNoteDayRequest(
          id: id,
          data: data,
          updateMask: updateMask,
          allowMissing: allowMissing,
        ),
      ));

  /// 删除提醒
  Future<dynamic> delete(int id) =>
      call(() async { await _api.delete(LedgerServiceV1DeleteNoteDayRequest(id: id)); });

  /// 立即执行一次提醒（生成流水）
  Future<dynamic> run(int id) =>
      call(() => _api.run(LedgerServiceV1RunNoteDayRequest(id: id)));

  /// 撤回已执行的提醒（删除对应流水）
  Future<dynamic> recall(int id) =>
      call(() => _api.recall(LedgerServiceV1RecallNoteDayRequest(id: id)));
}
