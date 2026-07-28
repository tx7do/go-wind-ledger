import 'package:dio/dio.dart' show DioException;
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
  Future<dynamic> list([PaginationQuery? query]) async {
    final q = query ?? const PaginationQuery();
    try {
      return await _api.list(q.toPagingRequest());
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 获取单个提醒
  Future<dynamic> get(int id) async {
    try {
      return await _api.get(LedgerServiceV1GetNoteDayRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 创建提醒
  Future<dynamic> create(NoteDay data) async {
    try {
      return await _api.create(LedgerServiceV1CreateNoteDayRequest(data: data));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 更新提醒
  Future<dynamic> update(
    int id,
    NoteDay data, {
    String? updateMask,
    bool? allowMissing,
  }) async {
    try {
      return await _api.update(
        LedgerServiceV1UpdateNoteDayRequest(
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

  /// 删除提醒
  Future<dynamic> delete(int id) async {
    try {
      await _api.delete(LedgerServiceV1DeleteNoteDayRequest(id: id));
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 立即执行一次提醒（生成流水）
  Future<dynamic> run(int id) async {
    try {
      return await _api.run(LedgerServiceV1RunNoteDayRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 撤回已执行的提醒（删除对应流水）
  Future<dynamic> recall(int id) async {
    try {
      return await _api.recall(LedgerServiceV1RecallNoteDayRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }
}
