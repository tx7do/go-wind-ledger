# API 层开发指南

本文档面向二开人员，介绍 GoWind ledger Flutter 端的 API 架构设计、代码生成流程、Service 编写规范和分页查询机制。

> 更全面的编码规范（目录结构、约定、分层模板、Checklist）见同级 [AGENTS.md](../AGENTS.md)。

---

## 1. 整体架构

```
┌─────────────────────────────────────────────────────────┐
│  UI 层（Page / Widget）                                  │
│  调用 Service 方法，处理返回数据                            │
├─────────────────────────────────────────────────────────┤
│  Service 层（lib/src/features/ledger/services/）         │
│  业务封装，异常处理，typedef 短类名                         │
│  继承 BaseService → handleDioError()                     │
├─────────────────────────────────────────────────────────┤
│  生成层（lib/generated/api/app/service/v1/）             │
│  ApiClient → XxxServiceClient（protoc-gen-dart-http）   │
│  Transport（DioClientTransport 适配 Dio）                │
├─────────────────────────────────────────────────────────┤
│  传输层（lib/src/core/transport/）                       │
│  Dio 实例 + 拦截器（认证、日志、locale、错误处理）          │
│  环境配置（.env → Environments.apiBaseUrl）               │
└─────────────────────────────────────────────────────────┘
```

**调用链路：** `Page → Service → ApiClient.XxxService → DioClientTransport → Dio → HTTP`

---

## 2. 代码生成流程

后端 proto 定义（`api/protos/app/service/v1/*.proto`）通过 **protoc-gen-dart-http** 自动生成 Dart API 客户端代码，无需手写网络请求。

### 2.1 入口命令

```bash
# 生成 API client + 数据模型（proto 变更后必须执行）
dart run build_runner build --delete-conflicting-outputs
```

### 2.2 生成流程

```
api/protos/app/service/v1/*.proto
  ↓ protoc-gen-dart-http 解析 proto（gRPC service + google.api.http 注解）
  ↓ 生成 ApiClient + 各 XxxServiceClient + Transport
  ↓ build_runner 编译 .g.dart（JSON 序列化 / freezed）
lib/generated/api/app/service/v1/
```

### 2.3 生成产物

```
lib/generated/api/app/service/v1/
├── index.dart                   # 聚合入口，定义 ApiClient（持有所有 ServiceClient）
├── account_service.pb.dart      # AccountServiceClient + Account 等 message 模型
├── budget_service.pb.dart       # BudgetServiceClient + Budget 等 message 模型
└── ...                          # 其他 service 文件
```

### 2.4 重要原则

- **禁止手动编辑** `lib/generated/` 下的任何文件
- 修改后端 proto 后，重新运行 `dart run build_runner build --delete-conflicting-outputs`
- 生成的模型类名较长（如 `LedgerServiceV1Account`），通过 typedef 映射短类名

---

## 3. 传输层

### 3.1 Dio 初始化

文件：`lib/src/core/transport/http/http_client.dart`

```dart
Dio createDio() {
  final dio = Dio();
  dio.options.baseUrl = Environments.apiBaseUrl;    // 从 .env 读取
  dio.options.connectTimeout = Environments.connectionTimeout;
  dio.options.receiveTimeout = Environments.receiveTimeout;
  dio.options.responseType = ResponseType.json;
  // ...
  return dio;
}
```

Dio 实例通过 GetIt 注册为全局单例：

```dart
// lib/src/core/transport/init.dart
getIt.registerLazySingleton<Dio>(() => createDio());
```

### 3.2 环境配置

文件：`lib/src/core/config/environments.dart`

通过 `flutter_dotenv` 从 `.env`（生产）或 `.dev.env`（开发）加载：

```env
# .dev.env
API_BASE_URL="https://api.gowind.cloud"
CONNECTION_TIMEOUT=3000
RECEIVE_TIMEOUT=3000
```

### 3.3 ApiClient 聚合入口

文件：`lib/generated/api/app/service/v1/index.dart`

`ApiClient` 是所有 ServiceClient 的聚合入口，内部通过 `DioClientTransport` 适配 Dio 单例，各 ServiceClient 懒加载。ApiClient 通过 GetIt 全局获取：

```dart
// lib/src/init.dart
getIt.registerLazySingleton<ApiClient>(() => ApiClient(DioClientTransport(...)));

// 获取 ApiClient 单例
final api = GetIt.instance<ApiClient>();

// 懒加载各 ServiceClient
api.accountService          // AccountServiceClient
api.balanceFlowService      // BalanceFlowServiceClient
api.bookService             // BookServiceClient
api.bookTemplateService     // BookTemplateServiceClient
api.budgetService           // BudgetServiceClient
api.currencyService         // CurrencyServiceClient
api.fileTransferService     // FileTransferServiceClient
api.flowFileService         // FlowFileServiceClient
api.ledgerAuthService       // LedgerAuthServiceClient
api.ledgerCategoryService   // LedgerCategoryServiceClient
api.ledgerTagService        // LedgerTagServiceClient
api.noteDayService          // NoteDayServiceClient
api.payeeService            // PayeeServiceClient
api.reportService           // ReportServiceClient
api.tenantMemberService     // TenantMemberServiceClient
api.authenticationService   // AuthenticationServiceClient（认证登录）
api.userProfileService      // UserProfileServiceClient（用户资料）
```

---

## 4. Service 层编写规范

### 4.1 标准 Service 结构

以 `AccountService` 为例（标准范式：继承 BaseService + GetIt 获取 ApiClient + try/catch + handleDioError）：

```dart
// lib/src/features/ledger/services/account_service.dart

// ① import 生成模型，用 typedef 定义短类名
typedef Account = LedgerServiceV1Account;
typedef ListAccountResponse = LedgerServiceV1ListAccountResponse;

// ② 继承 BaseService
class AccountService extends BaseService {
  AccountService() : super(tag: 'AccountService');

  // ③ 通过 GetIt 获取 ApiClient，访问对应的 ServiceClient
  AccountServiceClient get _api => GetIt.instance<ApiClient>().accountService;

  // ④ 直接调用方法（try-catch + handleDioError）
  Future<dynamic> list([PaginationQuery? query]) async {
    final q = query ?? const PaginationQuery();
    try {
      return await _api.list(q.toPagingRequest());
    } on DioException catch (e) {
      return handleDioError(e);   // Dio 异常 → Status 对象
    }
  }

  Future<dynamic> get(int id) async {
    try {
      return await _api.get(LedgerServiceV1GetAccountRequest(id: id));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  Future<dynamic> create(Account data) async {
    try {
      return await _api.create(LedgerServiceV1CreateAccountRequest(data: data));
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }
}
```

### 4.2 typedef 短类名规范

生成模型的完整类名较长（如 `LedgerServiceV1Account`），在 Service 文件顶部统一用 typedef 映射：

```dart
// 在 service 文件顶部
typedef Account = LedgerServiceV1Account;
typedef Book = LedgerServiceV1Book;
```

外部使用时直接 `import` service 文件，通过 typedef 使用短类名。

### 4.3 异常处理模式

所有 Service 方法统一使用 `try-catch + handleDioError`：

```dart
Future<dynamic> get(int id) async {
  try {
    return await _api.get(LedgerServiceV1GetAccountRequest(id: id));
  } on DioException catch (e) {
    return handleDioError(e);  // → Status(code, reason, message)
  }
}
```

`handleDioError` 定义在 `BaseService` 中，将 Dio 异常转为统一的 `Status` 对象：

```dart
// lib/src/core/services/base_service.dart
Status handleDioError(DioException e) {
  final data = e.response?.data;
  if (data is Map<String, dynamic>) {
    return Status(
      code: e.response?.statusCode,
      reason: data['reason'],
      message: data['message'],
    );
  }
  return Status(code: e.response?.statusCode, message: e.message);
}
```

### 4.4 返回值约定

Service 方法统一返回 `Future<dynamic>`，调用方需判断返回类型：

| 方法类型         | 成功返回                     | 失败返回        |
|--------------|--------------------------|-------------|
| 查询（list/get） | `XxxResponse` 或 `Xxx` 模型 | `Status` 对象 |
| 创建（create）   | 创建的资源模型                  | `Status` 对象 |
| 更新（update）   | 更新后的资源模型                 | `Status` 对象 |
| 删除（delete）   | `null`                   | `Status` 对象 |

**调用方需要判断返回类型：**

```dart
final result = await _accountService.list(query);
if (result is ListAccountResponse) {
  // 成功，使用 result.items
} else if (result is Status) {
  // 失败，显示 result.message
}
```

### 4.5 无生成客户端时的降级方案

当后端尚未补齐 BFF 路由、生成代码中暂无对应 `XxxServiceClient` 时，可参照 `BudgetService` 直接使用 `GetIt.instance<Dio>()` 单例调用 REST 接口，并手写 `fromJson` / `toJson`：

```dart
// lib/src/features/ledger/services/budget_service.dart
class BudgetService extends BaseService {
  BudgetService() : super(tag: 'BudgetService');

  Dio get _dio => GetIt.instance<Dio>();

  static const String _base = '/app/v1/budgets';

  Future<dynamic> listAll({int? bookId}) async {
    try {
      final qs = <String>[];
      if (bookId != null) qs.add('bookId=$bookId');
      final path = qs.isEmpty ? _base : '$_base/all?${qs.join('&')}';
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
}
```

**何时使用此模式：**

- 后端 REST 接口已就绪，但 proto/BFF 尚未补齐 → 临时用直接 Dio 调用
- 待后端补齐 BFF 路由并重新生成客户端后，可平滑迁移到标准范式（4.1）

**与标准范式的差异：**

| 维度 | 标准范式（4.1） | 降级方案（4.5） |
|------|--------------|--------------|
| API 入口 | `GetIt.instance<ApiClient>().xxxService` | `GetIt.instance<Dio>()` |
| 数据模型 | 生成层 message（LedgerServiceV1Xxx） | 手写 fromJson/toJson |
| 路径管理 | 生成层自动 | 手写常量 `_base` |
| 异常处理 | handleDioError | handleDioError（相同） |

### 4.6 parseInt 整数安全解析

**背景问题**：protojson 序列化时，`int64` / `uint64` 字段会被序列化为**字符串**（如 `"123"` 而非 `123`），导致直接 `as num` 转换失败。

**解决方案**：使用 `lib/src/core/utilities/convert.dart` 中的 `parseInt()`，兼容 `int` / `num` / `String` 三种输入：

```dart
// lib/src/core/utilities/convert.dart
int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
    // 可能是 double 字符串如 "0.0"
    final d = double.tryParse(value);
    return d?.toInt();
  }
  return null;
}
```

**使用场景**：在 4.5 降级方案的手写 `fromJson` 中，所有整数字段必须用 `parseInt()` 解析：

```dart
factory Budget.fromJson(Map<String, dynamic> json) {
  return Budget(
    id: parseInt(json['id']),           // 可能是 "123" 或 123
    tenantId: parseInt(json['tenantId']),
    bookId: parseInt(json['bookId']),
    categoryId: parseInt(json['categoryId']),
    // 字符串字段直接 cast
    name: json['name'] as String?,
    amount: json['amount'] as String?,
    // ...
  );
}
```

> ⚠️ **注意**：标准范式（4.1）中使用的生成层 message 模型已由 protoc-gen-dart-http 正确处理 int64 序列化，无需手动 `parseInt`。只有 4.5 降级方案的手写 `fromJson` 才需要。

---

## 5. 分页查询（PaginationQuery）

### 5.1 概述

文件：`lib/src/core/services/pagination_query.dart`

统一封装所有 List API 的查询参数，通过 `toPagingRequest()` 转换为生成代码所需的 `PaginationPagingRequest`。

### 5.2 核心参数

```dart
PaginationQuery(
  page: 1,                    // 页码（从 1 开始）
  pageSize: 10,               // 每页条数
  formValues: {               // 过滤条件 → 序列化为 JSON query 字符串
    'category_id': 5,
    'status': 'published',
  },
  orderBy: ['-created_at'],   // 排序（默认 ['-created_at']）
  fieldMask: 'id,title',      // 字段白名单（SELECT）
  isTenantUser: false,         // 是否清理租户字段
);
```

### 5.3 计算属性与方法

| 属性/方法              | 说明                                               |
|----------------------|--------------------------------------------------|
| `noPaging`           | `page == null && pageSize == null` 时为 true（全量加载） |
| `queryString`        | `formValues` + `locale` 合并为 JSON 字符串，自动清理 null   |
| `orderByString`      | 排序列表 → JSON 数组字符串                                |
| `formattedFieldMask` | `List<String>` → 逗号分隔，`String` → 原样              |
| `toPagingRequest()`  | 转换为生成代码的 `PaginationPagingRequest`（供 ServiceClient.list 使用） |
| `nextPage()`         | 返回页码 +1 的新查询对象                                   |

### 5.4 常用场景

```dart
// 全量加载（不分页）
_accountService.list(const PaginationQuery());

// 分页加载
_accountService.list(PaginationQuery(page: 1, pageSize: 10));

// 带过滤条件
_accountService.list(PaginationQuery(
  formValues: {'category_id': 5},
));

// 下一页
query = query.nextPage();
```

### 5.5 locale 自动注入

`PaginationQuery` 会自动从 `UserPreferenceCache` 读取用户语言偏好，注入到 `query` 的 `locale` 字段。对于不支持 locale 参数的 API，可在构造时跳过（见 `PaginationQuery` 源码）。

---

## 6. 认证服务

### 6.1 认证拦截器

文件：`lib/src/core/transport/http/interceptors/`

拦截器链：Token 注入 → Locale → 请求日志 → 响应数据解构 → 401 认证处理 → 错误消息提取

功能：
- 自动在请求头添加 `Authorization: Bearer <token>`
- 401 响应时自动刷新 token
- 刷新失败触发 `authenticationFailed()` 回调

### 6.2 LedgerAuthService

文件：`lib/src/features/ledger/services/ledger_auth_service.dart`

覆盖注册 / 初始化状态 / 设置默认账本 / 设置默认租户等扩展认证能力（与 `AuthenticationService` 的登录流程不同）：

```dart
class LedgerAuthService extends BaseService {
  LedgerAuthServiceClient get _api =>
      GetIt.instance<ApiClient>().ledgerAuthService;

  // 用户注册（后端自动创建默认租户和账本）
  Future<dynamic> register(String username, String password, {String? inviteCode, String? nickName});

  // 初始化状态（返回当前用户/租户/账本聚合信息）
  Future<dynamic> initState();

  // 设置默认账本
  Future<dynamic> setDefaultBook(int bookId);

  // 设置默认租户
  Future<dynamic> setDefaultTenant(int tenantId);
}
```

> 注意：注册接口在后端以明文接收并存储密码（不走 AES 解密分支），因此 `register()` 直接透传明文密码，以保证注册后用户可正常登录。

---

## 7. 文件传输

文件：`lib/src/features/ledger/services/flow_file_service.dart`

通过 `GetIt.instance<ApiClient>().flowFileService` 调用流水附件接口，支持文件上传/下载。

---

## 8. 新增 API 接入 Checklist

当后端新增或修改 API 后，按以下步骤操作：

1. **重新生成代码**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **检查生成产物** — 确认 `lib/generated/api/app/service/v1/` 下有对应的 ServiceClient 和 message 模型

3. **新建或更新 Service**
   - 在 `lib/src/features/ledger/services/` 下新建或编辑 Service 文件
   - 继承 `BaseService`
   - 顶部添加 `typedef` 短类名
   - 通过 `GetIt.instance<ApiClient>().xxxService` 获取 ServiceClient
   - 实现 CRUD 方法，统一 `try-catch + handleDioError`

4. **若无生成客户端** — 参照第 4.5 节降级方案，用 `GetIt.instance<Dio>()` 直接调用 REST 接口，手写 `fromJson`/`toJson` 并用 `parseInt()` 解析整数

5. **使用 Service**
   - 在 Page/Widget 中 import Service
   - 调用方法，判断返回类型（模型 vs Status）

---

## 9. 现有 Service 清单

| Service              | 文件                          | 说明                 |
|----------------------|-----------------------------|--------------------|
| AccountService       | `account_service.dart`      | 账户 CRUD、余额调整、概览  |
| BalanceFlowService   | `balance_flow_service.dart` | 流水 CRUD            |
| BookService          | `book_service.dart`         | 账本 CRUD、账本模板       |
| BudgetService        | `budget_service.dart`       | 预算 CRUD、进度（降级方案）   |
| CategoryService      | `category_service.dart`     | 分类 CRUD（树形）       |
| CurrencyService      | `currency_service.dart`     | 币种查询               |
| FlowFileService      | `flow_file_service.dart`    | 流水附件               |
| LedgerAuthService    | `ledger_auth_service.dart`  | 注册、初始化状态、默认账本/租户   |
| NoteDayService       | `note_day_service.dart`     | 定期提醒 CRUD          |
| PayeeService         | `payee_service.dart`        | 收款人 CRUD           |
| ReportService        | `report_service.dart`       | 统计报表               |
| TagService           | `tag_service.dart`          | 标签 CRUD（树形）        |
| TenantMemberService  | `tenant_member_service.dart`| 租户成员管理             |

---

## 10. 相关文件索引

| 文件路径                                                        | 说明                       |
|---------------------------------------------------------------|--------------------------|
| `lib/src/init.dart`                                           | 应用初始化（ApiClient / Dio 注册） |
| `lib/generated/api/app/service/v1/index.dart`                 | API 聚合入口（ApiClient）      |
| `lib/src/core/services/base_service.dart`                     | Service 基类（异常处理）         |
| `lib/src/core/services/pagination_query.dart`                 | 分页查询封装                   |
| `lib/src/core/utilities/convert.dart`                         | 工具函数（parseInt 等安全解析）     |
| `lib/src/core/transport/http/http_client.dart`                | Dio 初始化                  |
| `lib/src/core/transport/init.dart`                            | 传输层注册（Dio 单例）            |
| `lib/src/core/transport/http/status.dart`                     | Status 错误对象              |
| `lib/src/core/config/environments.dart`                       | 环境变量                     |
| `.dev.env` / `.env`                                           | 环境配置文件                   |

---

## 11. 主题与语言管理

### 11.1 AppThemeCubit

文件：`lib/src/core/themes/cubit/app_theme_cubit.dart`

通过 `AppThemeCubit`（BLoC/Cubit）全局管理主题模式、主题色、语言，使用 SharedPreferences 持久化：

| 能力 | 方法 | 说明 |
|------|------|------|
| 主题模式 | `modify(ThemeMode)` | 切换 light / dark / system |
| 主题色 | `modifySeedColor(Color)` | 切换 Material 3 seed color |
| 语言 | `modifyLocale(Locale)` | 切换语言（持久化到 UserPreferenceCache） |
| 初始化 | `init()` | 从缓存读取已保存的偏好 |

### 11.2 接入方式

设置页（`lib/src/features/ledger/pages/settings_page.dart`）提供 UI 入口，通过 `context.watch<AppThemeCubit>()` 响应式读取当前状态：

```dart
// 主题模式切换（SegmentedButton）
Widget _buildThemeModeSwitcher(ThemeData theme) {
  final cubit = context.watch<AppThemeCubit>();
  return SegmentedButton<ThemeMode>(
    segments: const [
      ButtonSegment(value: ThemeMode.light, label: Text('亮色')),
      ButtonSegment(value: ThemeMode.dark, label: Text('暗色')),
      ButtonSegment(value: ThemeMode.system, label: Text('跟随系统')),
    ],
    selected: {cubit.themeMode},
    onSelectionChanged: (mode) => cubit.modify(mode.first),
  );
}

// 主题色选择（圆形色板）
Widget _buildColorPicker(ThemeData theme) {
  final cubit = context.watch<AppThemeCubit>();
  // cubit.modifySeedColor(color)
}

// 语言切换
Widget _buildLanguageSwitcher(ThemeData theme) {
  final cubit = context.watch<AppThemeCubit>();
  // cubit.supportedLocales / cubit.modifyLocale(locale)
}
```

### 11.3 支持的语言

通过 `l10n.S.delegate.supportedLocales` 获取（当前为 `zh_CN` / `en_US`），新增语言见 [SKILL.md](../SKILL.md) 的 `add-i18n` 技能。
