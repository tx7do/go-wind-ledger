import 'package:dio/dio.dart' show Dio, DioException;
import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

/// 预算周期类型。
///
/// 与 ledger.service.v1.BudgetPeriod 对应，序列化为字符串传输。
enum BudgetPeriod {
  unspecified('BUDGET_PERIOD_UNSPECIFIED'),
  monthly('BUDGET_PERIOD_MONTHLY'),
  yearly('BUDGET_PERIOD_YEARLY'),
  quarterly('BUDGET_PERIOD_QUARTERLY'),
  weekly('BUDGET_PERIOD_WEEKLY');

  final String wire;
  const BudgetPeriod(this.wire);

  static BudgetPeriod fromWire(String? value) {
    for (final v in BudgetPeriod.values) {
      if (v.wire == value) return v;
    }
    return BudgetPeriod.unspecified;
  }
}

/// 预算模型（对应 ledger.service.v1.Budget）。
class Budget {
  final int? id;
  final int? tenantId;
  final int? bookId;
  final String? name;
  final BudgetPeriod period;
  final String? amount;
  final String? usedAmount;
  final int? categoryId;
  final int? accountId;
  final int? startDate;
  final int? endDate;
  final bool? enable;
  final bool? notify;
  final String? notes;

  Budget({
    this.id,
    this.tenantId,
    this.bookId,
    this.name,
    this.period = BudgetPeriod.unspecified,
    this.amount,
    this.usedAmount,
    this.categoryId,
    this.accountId,
    this.startDate,
    this.endDate,
    this.enable,
    this.notify,
    this.notes,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: (json['id'] as num?)?.toInt(),
      tenantId: (json['tenantId'] as num?)?.toInt(),
      bookId: (json['bookId'] as num?)?.toInt(),
      name: json['name'] as String?,
      period: BudgetPeriod.fromWire(json['period'] as String?),
      amount: json['amount'] as String?,
      usedAmount: json['usedAmount'] as String?,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      accountId: (json['accountId'] as num?)?.toInt(),
      startDate: (json['startDate'] as num?)?.toInt(),
      endDate: (json['endDate'] as num?)?.toInt(),
      enable: json['enable'] as bool?,
      notify: json['notify'] as bool?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (id != null) json['id'] = id;
    if (tenantId != null) json['tenantId'] = tenantId;
    if (bookId != null) json['bookId'] = bookId;
    if (name != null) json['name'] = name;
    json['period'] = period.wire;
    if (amount != null) json['amount'] = amount;
    if (usedAmount != null) json['usedAmount'] = usedAmount;
    if (categoryId != null) json['categoryId'] = categoryId;
    if (accountId != null) json['accountId'] = accountId;
    if (startDate != null) json['startDate'] = startDate;
    if (endDate != null) json['endDate'] = endDate;
    if (enable != null) json['enable'] = enable;
    if (notify != null) json['notify'] = notify;
    if (notes != null) json['notes'] = notes;
    return json;
  }

  Budget copyWith({
    int? id,
    int? tenantId,
    int? bookId,
    String? name,
    BudgetPeriod? period,
    String? amount,
    String? usedAmount,
    int? categoryId,
    int? accountId,
    int? startDate,
    int? endDate,
    bool? enable,
    bool? notify,
    String? notes,
  }) {
    return Budget(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      period: period ?? this.period,
      amount: amount ?? this.amount,
      usedAmount: usedAmount ?? this.usedAmount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      enable: enable ?? this.enable,
      notify: notify ?? this.notify,
      notes: notes ?? this.notes,
    );
  }
}

/// 预算进度（对应 ledger.service.v1.BudgetProgress）。
class BudgetProgress {
  final int? budgetId;
  final String? budgetName;
  final String? amount;
  final String? usedAmount;
  final String? remaining;
  final String? usagePercent;
  final bool? exceeded;
  final int? periodStart;
  final int? periodEnd;

  BudgetProgress({
    this.budgetId,
    this.budgetName,
    this.amount,
    this.usedAmount,
    this.remaining,
    this.usagePercent,
    this.exceeded,
    this.periodStart,
    this.periodEnd,
  });

  factory BudgetProgress.fromJson(Map<String, dynamic> json) {
    return BudgetProgress(
      budgetId: (json['budgetId'] as num?)?.toInt(),
      budgetName: json['budgetName'] as String?,
      amount: json['amount'] as String?,
      usedAmount: json['usedAmount'] as String?,
      remaining: json['remaining'] as String?,
      usagePercent: json['usagePercent'] as String?,
      exceeded: json['exceeded'] as bool?,
      periodStart: (json['periodStart'] as num?)?.toInt(),
      periodEnd: (json['periodEnd'] as num?)?.toInt(),
    );
  }
}

/// 预算列表响应。
class ListBudgetResponse {
  final List<Budget> items;
  final int total;

  ListBudgetResponse({this.items = const [], this.total = 0});

  factory ListBudgetResponse.fromJson(Map<String, dynamic> json) {
    return ListBudgetResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Budget.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 预算服务
///
/// 通过 GetIt 获取共享 [Dio] 单例，调用 app BFF 预算 REST 接口
/// （`/app/v1/budgets`）。当前 Dart 客户端尚未包含 BudgetServiceClient，
/// 待后端补齐 BFF 路由并重新生成客户端后可平滑迁移。
class BudgetService extends BaseService {
  BudgetService() : super(tag: 'BudgetService');

  Dio get _dio => GetIt.instance<Dio>();

  static const String _base = '/app/v1/budgets';

  /// 获取所有预算（不分页，可按账本过滤）
  Future<dynamic> listAll({int? bookId}) async {
    try {
      final qs = <String>[];
      if (bookId != null) qs.add('bookId=$bookId');
      final path =
          qs.isEmpty ? _base : '$_base/all?${qs.join('&')}';
      final resp = await _dio.get<dynamic>(path);
      final data = resp.data;
      if (data is Map<String, dynamic>) {
        return ListBudgetResponse.fromJson(data);
      }
      return ListBudgetResponse();
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 获取单个预算
  Future<dynamic> get(int id) async {
    try {
      final resp = await _dio.get<dynamic>('$_base/$id');
      final data = resp.data;
      if (data is Map<String, dynamic>) {
        return Budget.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 创建预算
  Future<dynamic> create(Budget data) async {
    try {
      final resp = await _dio.post<dynamic>(
        _base,
        data: data.toJson(),
      );
      final body = resp.data;
      if (body is Map<String, dynamic>) {
        return Budget.fromJson(body);
      }
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 更新预算
  Future<dynamic> update(int id, Budget data,
      {String? updateMask, bool? allowMissing}) async {
    try {
      final resp = await _dio.put<dynamic>(
        '$_base/$id',
        data: data.toJson(),
      );
      final body = resp.data;
      if (body is Map<String, dynamic>) {
        return Budget.fromJson(body);
      }
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 删除预算
  Future<dynamic> delete(int id) async {
    try {
      await _dio.delete<dynamic>('$_base/$id');
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 获取预算进度（已用金额/预算金额）
  Future<dynamic> getProgress(int id) async {
    try {
      final resp = await _dio.get<dynamic>('$_base/$id/progress');
      final data = resp.data;
      if (data is Map<String, dynamic>) {
        return BudgetProgress.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }
}
