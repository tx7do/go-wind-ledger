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
  Future<dynamic> list([PaginationQuery? query]) {
    final q = query ?? const PaginationQuery();  return call(() => _api.list(q.toPagingRequest()););
  }

  /// 获取所有标签（不分页，可按账本过滤）
  Future<dynamic> listAll({int? bookId}) =>
      call(() => _api
          .listAll(LedgerServiceV1ListAllTagRequest(bookId: bookId)));

  /// 获取单个标签
  Future<dynamic> get(int id) =>
      call(() => _api.get(LedgerServiceV1GetTagRequest(id: id)));

  /// 创建标签
  Future<dynamic> create(LedgerTag data) =>
      call(() => _api.create(LedgerServiceV1CreateTagRequest(data: data)));

  /// 更新标签
  Future<dynamic> update(
    int id,
    LedgerTag data, {
    String? updateMask,
    bool? allowMissing,
  }) =>
      call(() => _api.update(
        LedgerServiceV1UpdateTagRequest(
          id: id,
          data: data,
          updateMask: updateMask,
          allowMissing: allowMissing,
        ),
      ));

  /// 删除标签
  Future<dynamic> delete(int id) =>
      call(() async { await _api.delete(LedgerServiceV1DeleteTagRequest(id: id)); });

  /// 切换启用/禁用
  Future<dynamic> toggle(int id) =>
      call(() => _api.toggle(LedgerServiceV1ToggleTagRequest(id: id)));
}
