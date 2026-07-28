import 'package:dio/dio.dart' show DioException;
import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        LedgerCategoryServiceClient,
        LedgerServiceV1Category,
        LedgerServiceV1CategoryType,
        LedgerServiceV1ListCategoryResponse,
        LedgerServiceV1ListAllCategoryRequest,
        LedgerServiceV1GetCategoryRequest,
        LedgerServiceV1CreateCategoryRequest,
        LedgerServiceV1UpdateCategoryRequest,
        LedgerServiceV1DeleteCategoryRequest,
        LedgerServiceV1ToggleCategoryRequest;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/services/pagination_query.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

typedef Category = LedgerServiceV1Category;
typedef ListCategoryResponse = LedgerServiceV1ListCategoryResponse;

/// 分类服务（记账业务用 LedgerCategoryService）
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [LedgerCategoryServiceClient] 的方法。
class CategoryService extends BaseService {
  CategoryService() : super(tag: 'LedgerCategoryService');

  LedgerCategoryServiceClient get _api =>
      GetIt.instance<ApiClient>().ledgerCategoryService;

  /// 获取分类列表（分页）
  Future<dynamic> list([PaginationQuery? query]) async {
    final q = query ?? const PaginationQuery();
    try {
      return await _api.list(q.toPagingRequest());
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 获取所有分类（不分页，可按账本/类型过滤）
  Future<dynamic> listAll({
    int? bookId,
    LedgerServiceV1CategoryType? type,
  }) async {
    try {
      return await _api.listAll(
        LedgerServiceV1ListAllCategoryRequest(bookId: bookId, type: type),
      );
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 获取单个分类
  Future<dynamic> get(int id) async {
    try {
      return await _api.get(LedgerServiceV1GetCategoryRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 创建分类
  Future<dynamic> create(Category data) async {
    try {
      return await _api
          .create(LedgerServiceV1CreateCategoryRequest(data: data));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 更新分类
  Future<dynamic> update(
    int id,
    Category data, {
    String? updateMask,
    bool? allowMissing,
  }) async {
    try {
      return await _api.update(
        LedgerServiceV1UpdateCategoryRequest(
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

  /// 删除分类
  Future<dynamic> delete(int id) async {
    try {
      await _api.delete(LedgerServiceV1DeleteCategoryRequest(id: id));
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 切换启用/禁用
  Future<dynamic> toggle(int id) async {
    try {
      return await _api.toggle(LedgerServiceV1ToggleCategoryRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }
}
