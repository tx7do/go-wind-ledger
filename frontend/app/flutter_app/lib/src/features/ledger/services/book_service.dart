import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        BookServiceClient,
        BookTemplateServiceClient,
        LedgerServiceV1Book,
        LedgerServiceV1ListBookResponse,
        LedgerServiceV1BookTemplate,
        LedgerServiceV1ListAllBookRequest,
        LedgerServiceV1GetBookRequest,
        LedgerServiceV1CreateBookRequest,
        LedgerServiceV1CreateBookByTemplateRequest,
        LedgerServiceV1UpdateBookRequest,
        LedgerServiceV1DeleteBookRequest,
        LedgerServiceV1ToggleBookRequest;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/services/pagination_query.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

typedef Book = LedgerServiceV1Book;
typedef ListBookResponse = LedgerServiceV1ListBookResponse;
typedef BookTemplate = LedgerServiceV1BookTemplate;

/// 账本服务
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [BookServiceClient] 的方法。
class BookService extends BaseService {
  BookService() : super(tag: 'BookService');

  BookServiceClient get _api => GetIt.instance<ApiClient>().bookService;
  BookTemplateServiceClient get _templateApi =>
      GetIt.instance<ApiClient>().bookTemplateService;

  /// 获取所有账本模板
  Future<dynamic> listTemplates() =>
      call(() => _templateApi.listAll({}));

  /// 从模板创建账本（会一并创建模板中的分类/标签/收款人）
  Future<dynamic> createByTemplate({
    required int templateId,
    required String name,
    required String defaultCurrencyCode,
    String? notes,
  }) =>
      call(() => _api.createByTemplate(
        LedgerServiceV1CreateBookByTemplateRequest(
          templateId: templateId,
          name: name,
          defaultCurrencyCode: defaultCurrencyCode,
          notes: notes,
        ),
      ));

  /// 获取账本列表（分页）
  Future<dynamic> list([PaginationQuery? query]) {
    final q = query ?? const PaginationQuery();  return call(() => _api.list(q.toPagingRequest()););
  }

  /// 获取所有账本（不分页）
  Future<dynamic> listAll({bool? includeDisabled}) =>
      call(() => _api.listAll(
        LedgerServiceV1ListAllBookRequest(includeDisabled: includeDisabled),
      ));

  /// 获取单个账本
  Future<dynamic> get(int id) =>
      call(() => _api.get(LedgerServiceV1GetBookRequest(id: id)));

  /// 创建账本
  Future<dynamic> create(Book data) =>
      call(() => _api.create(LedgerServiceV1CreateBookRequest(data: data)));

  /// 更新账本
  Future<dynamic> update(
    int id,
    Book data, {
    String? updateMask,
    bool? allowMissing,
  }) =>
      call(() => _api.update(
        LedgerServiceV1UpdateBookRequest(
          id: id,
          data: data,
          updateMask: updateMask,
          allowMissing: allowMissing,
        ),
      ));

  /// 删除账本
  Future<dynamic> delete(int id) =>
      call(() async { await _api.delete(LedgerServiceV1DeleteBookRequest(id: id)); });

  /// 切换启用/禁用
  Future<dynamic> toggle(int id) =>
      call(() => _api.toggle(LedgerServiceV1ToggleBookRequest(id: id)));
}
