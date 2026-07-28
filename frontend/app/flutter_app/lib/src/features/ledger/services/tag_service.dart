import 'package:dio/dio.dart' show DioException;
import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        LedgerTagServiceClient,
        LedgerServiceV1Tag,
        LedgerServiceV1ListTagResponse,
        LedgerServiceV1ListAllTagRequest,
        LedgerServiceV1GetTagRequest,
        LedgerServiceV1CreateTagRequest,
        LedgerServiceV1UpdateTagRequest,
        LedgerServiceV1DeleteTagRequest,
        LedgerServiceV1ToggleTagRequest;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/services/pagination_query.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

typedef LedgerTag = LedgerServiceV1Tag;
typedef ListTagResponse = LedgerServiceV1ListTagResponse;

/// 标签服务（记账业务用 LedgerTagService）
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [LedgerTagServiceClient] 的方法。
class TagService extends BaseService {
  TagService() : super(tag: 'LedgerTagService');

  LedgerTagServiceClient get _api =>
      GetIt.instance<ApiClient>().ledgerTagService;

  /// 获取标签列表（分页）
  Future<dynamic> list([PaginationQuery? query]) async {
    final q = query ?? const PaginationQuery();
    try {
      return await _api.list(q.toPagingRequest());
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 获取所有标签（不分页，可按账本过滤）
  Future<dynamic> listAll({int? bookId}) async {
    try {
      return await _api
          .listAll(LedgerServiceV1ListAllTagRequest(bookId: bookId));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 获取单个标签
  Future<dynamic> get(int id) async {
    try {
      return await _api.get(LedgerServiceV1GetTagRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 创建标签
  Future<dynamic> create(LedgerTag data) async {
    try {
      return await _api.create(LedgerServiceV1CreateTagRequest(data: data));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 更新标签
  Future<dynamic> update(
    int id,
    LedgerTag data, {
    String? updateMask,
    bool? allowMissing,
  }) async {
    try {
      return await _api.update(
        LedgerServiceV1UpdateTagRequest(
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

  /// 删除标签
  Future<dynamic> delete(int id) async {
    try {
      await _api.delete(LedgerServiceV1DeleteTagRequest(id: id));
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 切换启用/禁用
  Future<dynamic> toggle(int id) async {
    try {
      return await _api.toggle(LedgerServiceV1ToggleTagRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }
}
