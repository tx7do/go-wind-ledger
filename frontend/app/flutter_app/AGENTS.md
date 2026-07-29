# AGENTS.md — Flutter 全平台记账应用开发指南

> 本文件是 `frontend/app/flutter_app` 子项目的 AI 编码规范单一事实源，适用于所有支持 AGENTS.md 的 AI 编码工具。Claude Code 通过同级 `CLAUDE.md` 中的 `@AGENTS.md` 引用加载。

## 目录

- [项目概览](#项目概览)
- [关键架构认知](#关键架构认知)
- [目录结构](#目录结构)
- [关键约定（必须遵守）](#关键约定必须遵守)
- [代码生成](#代码生成改后必须重新生成)
- [开发命令与环境变量](#开发命令与环境变量)
- [分层架构模板](#分层架构模板)
- [新增业务模块 Checklist](#新增业务模块-checklist)
- [快速参考索引](#快速参考索引)
- [常见错误与纠正](#常见错误与纠正)
- [FAQ](#faq)

## 项目概览

基于 **Flutter** 的全平台个人/家庭记账应用，一套 Dart 代码编译为 iOS / Android / Web / macOS / Windows / Linux。

**核心技术栈**：Flutter 3.x (Dart 3.12+) + flutter_bloc/Cubit（状态管理）+ GoRouter（路由）+ GetIt（IoC）+ Dio + Retrofit（HTTP）+ protoc-gen-dart-http（API 生成）+ cached_query（缓存）+ flutter_screenutil（响应式）+ flutter_intl（i18n）+ Material 3

**代码生成工具链**：protoc-gen-dart-http（API client）+ intl_utils（i18n）+ build_runner + freezed + json_serializable + retrofit_generator

## 关键架构认知

### Feature-First 模块化架构

```
lib/
├── main.dart                    # 入口（init + MultiBlocProvider）
├── src/
│   ├── app.dart                 # LedgerApp（ScreenUtilInit + MaterialApp.router）
│   ├── init.dart                # 应用初始化（环境变量、传输层、仓库）
│   ├── app_router/              # GoRouter 路由配置 + 路由名称常量
│   │   ├── app_router.dart      #   GoRouter 实例（所有路由定义）
│   │   └── route_names.dart     #   路由名称常量
│   ├── core/                    # 核心基础设施
│   │   ├── config/              #   environments.dart（环境变量）
│   │   ├── constants/           #   breakpoints.dart / router_paths.dart / global.dart
│   │   ├── extensions/          #   扩展方法（context + protobuf helpers）
│   │   ├── logic/               #   Cubit/Bloc 状态管理（api / connectivity / page / text_changed / ui_state）
│   │   ├── preference/          #   UserPreferenceCache（SharedPreferences）
│   │   ├── repositories/        #   user_auth_cache（登录态 + Token）+ user_login_cache
│   │   ├── services/            #   base_service（统一错误处理）+ pagination_query
│   │   ├── themes/              #   cubit/（AppThemeCubit）+ light/dark_theme + fonts
│   │   ├── transport/http/      #   Dio + 拦截器（auth / request / response / whitelist）
│   │   ├── utilities/           #   convert / date_time / jwt_utils / logger / platform / strings / uuid
│   │   ├── utils/               #   responsive_utils（响应式）+ translation_helpers
│   │   └── widgets/             #   AppBackButton / AppBottomNavBar / ErrorPage / NotFoundPage / ResponsiveLayout / WebShellLayout
│   └── features/                # ★ Feature-First 业务模块
│       ├── auth/                #   认证模块
│       │   ├── pages/           #   login_page.dart / register_page.dart
│       │   └── services/        #   authentication_service.dart
│       └── ledger/              #   记账核心模块
│           ├── pages/           #   22 个页面（见下方列表）
│           ├── services/        #   13 个服务（见下方列表）
│           └── widgets/         #   4 个组件（见下方列表）
├── generated/                   # [自动生成] l10n.dart + api/
└── l10n/                        # i18n ARB 文件（intl_zh_CN.arb / intl_en_US.arb）
```

### 记账功能全景

**22 个页面 (`lib/src/features/ledger/pages/`):**

| 页面 | 文件 |
|------|------|
| 首页（Tab 导航） | `ledger_home_page.dart` |
| 账户列表 / 表单 / 概览 | `account_list_page.dart` / `account_form_page.dart` / `account_overview_page.dart` |
| 流水列表 / 表单 | `balance_flow_list_page.dart` / `balance_flow_form_page.dart` |
| 账本列表 / 表单 | `book_list_page.dart` / `book_form_page.dart` |
| 预算列表 / 表单 | `budget_list_page.dart` / `budget_form_page.dart` |
| 分类列表 / 表单 | `category_list_page.dart` / `category_form_page.dart` |
| 标签列表 / 表单 | `tag_list_page.dart` / `tag_form_page.dart` |
| 收款人列表 / 表单 | `payee_list_page.dart` / `payee_form_page.dart` |
| 提醒列表 / 表单 | `note_day_list_page.dart` / `note_day_form_page.dart` |
| 币种列表 | `currency_list_page.dart` |
| 成员列表 | `member_list_page.dart` |
| 报表 | `report_page.dart` |
| 设置 | `settings_page.dart` |

**13 个服务 (`lib/src/features/ledger/services/`):**

`account_service.dart`, `balance_flow_service.dart`, `book_service.dart`, `budget_service.dart`, `category_service.dart`, `currency_service.dart`, `flow_file_service.dart`, `ledger_auth_service.dart`, `note_day_service.dart`, `payee_service.dart`, `report_service.dart`, `tag_service.dart`, `tenant_member_service.dart`

**4 个组件 (`lib/src/features/ledger/widgets/`):**

`account_type_tag.dart`, `flow_type_selector.dart`, `ledger_bottom_nav.dart`, `statistics_card.dart`

### 三层 API 架构

```
lib/generated/api/app/service/v1/  # [自动生成] protoc-gen-dart-http 产出（ApiClient + 各 Service + Transport）
lib/src/features/ledger/services/  # [服务封装] 继承 BaseService，封装业务逻辑
lib/src/features/ledger/pages/     # [页面] 直接实例化 Service 调用
```

```dart
class AccountService extends BaseService {
  AccountServiceClient get _api => GetIt.instance<ApiClient>().accountService;

  Future<AccountListResponse> list([PaginationQuery? query]) async {
    try {
      return await _api.list(page: query?.page, pageSize: query?.pageSize, query: query?.queryString);
    } on DioException catch (e) {
      return handleDioError(e);  // 统一错误转换
    }
  }

  Future<Account> create(CreateAccountRequest req) async { /* ... */ }
  Future<Account> update(UpdateAccountRequest req) async { /* ... */ }
  Future<void> delete(String id) async { /* ... */ }
}
```

页面直接实例化 Service 调用，不额外封装 Hook。

### 响应式布局（三级断点）

| 设备 | 屏宽 | 布局策略 |
|------|------|----------|
| 手机 Mobile | < 600 dp | 纵向单栏 + 底部导航栏（LedgerBottomNav） |
| 平板 Tablet | 600~1024 dp | 双栏布局 |
| 网页 Web | > 1024 dp | 居中布局 + 持久化顶部导航栏（WebShellLayout） |

```dart
ResponsiveLayout(
  mobileBody: _buildMobileView(),
  webBody: _buildWebView(),
)
ResponsiveUtils.isMobile(context)        // 判断设备
ResponsiveUtils.postGridColumns(ctx)     // 网格列数（1/2/3）
```

**首页底部导航栏**（`LedgerBottomNav`）：流水(Flows) / 统计(Statistics) / 账户(Accounts) / 我的(Mine) 四个 Tab。

### Dio + ApiClient + GetIt（HTTP 通信）

- **ApiClient**（protoc-gen-dart-http 生成）通过 `DioClientTransport` 适配 Dio 单例
- Dio 全局单例通过 GetIt 注册
- 拦截器链：Token 注入 → Locale → 请求日志 → 响应数据解构 → 401 认证处理 → 错误消息提取
- `BaseService.handleDioError` 统一将 `DioException` 转为业务错误

### 状态管理 — BLoC / Cubit

- `AppThemeCubit`：全局状态（主题模式 / 主题色 / 语言），SharedPreferences 持久化
- API 请求用 `ApiCubit` / `ApiBloc` 管理 loading/data/error 三种状态
- 页面局部状态用 `StatefulWidget` + `setState`
- 登录状态通过 `UserAuthCache`（GetIt 单例）+ `ValueNotifier` 响应式

### 主题系统（Material 3 + ColorScheme.fromSeed）

```dart
ThemeData getLightTheme({Color? seedColor}) {
  final colorScheme = ColorScheme.fromSeed(seedColor: seedColor ?? kDefaultSeedColor, brightness: Brightness.light);
  return ThemeData(colorScheme: colorScheme, useMaterial3: true);
}
```

支持 `light` / `dark` / `system` 三种模式 + 8 种预设主题色。

### 国际化（flutter_intl + ARB）

```
lib/l10n/intl_zh_CN.arb / intl_en_US.arb   # 翻译源（~110 条消息）
lib/generated/l10n.dart                     # [生成] S 类
```

```dart
Text(S.of(context).appName)              // 获取翻译
Text(S.of(context).postsCount(5))        // 带参数
```

多语言内容获取用 `translation_helpers.dart` 辅助函数。

## 目录结构

```
flutter_app/
├── lib/
│   ├── main.dart                      # 入口
│   ├── src/
│   │   ├── app.dart                   # MaterialApp.router
│   │   ├── init.dart                  # 初始化
│   │   ├── app_router/                # GoRouter 路由
│   │   ├── core/                      # 基础设施（见上方架构）
│   │   └── features/
│   │       ├── auth/                  # 认证（2 页 + 1 服务）
│   │       └── ledger/                # 记账核心（22 页 + 13 服务 + 4 组件）
│   ├── generated/                     # [自动生成] l10n + api/transport
│   └── l10n/                          # ARB 翻译文件
├── assets/                            # 图片/字体资源
├── test/                              # 测试
├── pubspec.yaml
└── .dev.env / .env                    # 环境变量
```

## 关键约定（必须遵守）

1. **Service 必须继承 `BaseService`** — 用 `handleDioError` 统一处理 `DioException`
2. **分页用 `PaginationQuery`** — 不要手动拼接 query 字符串
3. **禁止手改 `lib/generated/`** — 由 protoc / intl_utils / build_runner 自动生成
4. **响应式用 `ResponsiveLayout`** — 不要在一个 build 方法混用 mobile/web 视图
5. **Web 端禁止 `.w` / `.h` / `.sp`** — Web 端 ScreenUtil designSize 设为视窗尺寸（1:1），用固定值；手机端可用
6. **断点用 `Breakpoints` 常量** — 不要硬编码屏宽数值
7. **路由用 `context.go()`（顶级切换）/ `context.push()`（子页面）** — 返回用 `AppBackButton`（内置 canPop 检查）
8. **路由路径集中管理** — `router_paths.dart` + `route_names.dart`
9. **多语言内容用辅助函数** — 如 `getPostTitle(post)`，不直接访问嵌套字段
10. **ApiClient 从 GetIt 获取** — `GetIt.instance<ApiClient>()`，不要手动 new
11. **API 请求务必 try/catch** — 捕获 `DioException` 并调用 `handleDioError`
12. **新增页面必须注册路由** — 在 `app_router.dart` 中添加 `GoRoute`，在 `route_names.dart` 添加名称常量

## 代码生成（改后必须重新生成）

| 修改内容 | 命令 |
|---|---|
| Proto / API 定义变更 | `dart run build_runner build --delete-conflicting-outputs` |
| ARB 翻译文件 | `flutter pub run intl_utils:generate` |
| Freezed 模型 / JsonSerializable | `dart run build_runner build --delete-conflicting-outputs` |

## 开发命令与环境变量

```bash
flutter pub get                              # 安装依赖
flutter pub run intl_utils:generate          # 生成 i18n
dart run build_runner build --delete-conflicting-outputs  # 生成 API/模型
flutter run -d chrome                        # Web 开发
flutter run -d ios / android                 # 移动端开发
flutter build web / apk / ios / macos / windows  # 构建生产产物
flutter analyze                              # 代码分析
flutter test                                 # 测试
```

**环境变量**（`.dev.env` Debug / `.env` Release，通过 flutter_dotenv 加载）：

```env
API_BASE_URL="https://api.gowind.cloud"
SSE_URL="https://sse.gowind.cloud/events"
CONNECTION_TIMEOUT=3000
RECEIVE_TIMEOUT=3000
AES_KEY="f51d66a73d8a0927"
```

## 分层架构模板

### Service 层模板

```dart
// lib/src/features/ledger/services/xxx_service.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart';
import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/services/pagination_query.dart';

class XxxService extends BaseService {
  XxxServiceClient get _api => GetIt.instance<ApiClient>().xxxService;

  Future<ListXxxResponse> list([PaginationQuery? query]) async {
    try {
      return await _api.list(
        page: query?.page,
        pageSize: query?.pageSize,
        query: query?.queryString,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Xxx> get(String id) async {
    try {
      return await _api.get(GetXxxRequest()..id = id);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Xxx> create(CreateXxxRequest req) async {
    try {
      return await _api.create(req);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Xxx> update(UpdateXxxRequest req) async {
    try {
      return await _api.update(req);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _api.delete(DeleteXxxRequest()..id = id);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
```

### 列表页模板

```dart
// lib/src/features/ledger/pages/xxx_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_app/src/core/widgets/responsive_layout.dart';
import 'package:flutter_app/src/core/widgets/app_back_button.dart';
import 'package:flutter_app/src/core/services/pagination_query.dart';
import 'package:flutter_app/src/features/ledger/services/xxx_service.dart';

class XxxListPage extends StatefulWidget {
  const XxxListPage({super.key});

  @override
  State<XxxListPage> createState() => _XxxListPageState();
}

class _XxxListPageState extends State<XxxListPage> {
  final _service = XxxService();
  List<Xxx> _items = [];
  bool _loading = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool refresh = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final query = PaginationQuery(page: refresh ? 1 : _page, pageSize: 20);
      final resp = await _service.list(query);
      setState(() {
        if (refresh) {
          _items = resp.items;
          _page = 1;
        } else {
          _items.addAll(resp.items);
        }
        _hasMore = resp.items.length >= 20;
        _page++;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildList(context),
      webBody: _buildList(context),
    );
  }

  Widget _buildList(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(S.of(context).xxxList),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/ledger/xxx/create'),
          ),
        ],
      ),
      body: _error != null
        ? ErrorPage(message: _error!, onRetry: () => _loadData(refresh: true))
        : RefreshIndicator(
            onRefresh: () => _loadData(refresh: true),
            child: ListView.builder(
              itemCount: _items.length + (_hasMore ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i >= _items.length) {
                  _loadData();
                  return const Center(child: CircularProgressIndicator());
                }
                final item = _items[i];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.description ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/ledger/xxx/${item.id}'),
                );
              },
            ),
          ),
    );
  }
}
```

### 表单页模板

```dart
// lib/src/features/ledger/pages/xxx_form_page.dart
import 'package:flutter/material.dart';

import 'package:flutter_app/src/core/widgets/app_back_button.dart';
import 'package:flutter_app/src/features/ledger/services/xxx_service.dart';
import 'package:flutter_app/generated/api/app/service/v1/index.dart';

class XxxFormPage extends StatefulWidget {
  final String? id;  // null = 新建，非 null = 编辑

  const XxxFormPage({super.key, this.id});

  @override
  State<XxxFormPage> createState() => _XxxFormPageState();
}

class _XxxFormPageState extends State<XxxFormPage> {
  final _service = XxxService();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  bool _isEdit = false;
  Xxx? _existing;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.id != null;
    if (_isEdit) _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final item = await _service.get(widget.id!);
      setState(() {
        _existing = item;
        _nameCtrl.text = item.name;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (_isEdit) {
        await _service.update(UpdateXxxRequest()
          ..id = widget.id!
          ..data = (Xxx()..name = _nameCtrl.text));
      } else {
        await _service.create(CreateXxxRequest()
          ..data = (Xxx()..name = _nameCtrl.text));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEdit ? 'Updated' : 'Created')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(_isEdit ? 'Edit Xxx' : 'Create Xxx'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _submit,
            child: _loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }
}
```

### 路由注册模板

在 `app_router.dart` 中添加：

```dart
// 列表路由
GoRoute(
  path: '/ledger/xxx',
  name: RouteNames.xxxList,
  builder: (context, state) => const XxxListPage(),
  routes: [
    // 新建
    GoRoute(
      path: 'create',
      name: RouteNames.xxxCreate,
      builder: (context, state) => const XxxFormPage(),
    ),
    // 编辑
    GoRoute(
      path: ':id',
      name: RouteNames.xxxDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return XxxFormPage(id: id);
      },
    ),
  ],
),
```

在 `route_names.dart` 中添加名称常量：

```dart
static const xxxList = 'xxxList';
static const xxxCreate = 'xxxCreate';
static const xxxDetail = 'xxxDetail';
```

## 新增业务模块 Checklist

```
- [ ] Step 1: 确认 API 已生成（lib/generated/api/ 中已有对应 ServiceClient）
- [ ] Step 2: 创建 Service（lib/src/features/ledger/services/xxx_service.dart，继承 BaseService）
- [ ] Step 3: 创建列表页（lib/src/features/ledger/pages/xxx_list_page.dart）
- [ ] Step 4: 创建表单页（lib/src/features/ledger/pages/xxx_form_page.dart）
- [ ] Step 5: 注册路由（app_router.dart + route_names.dart）
- [ ] Step 6: 添加导航入口（如首页 LedgerBottomNav 或相关列表页）
- [ ] Step 7: 添加 i18n 文本（intl_zh_CN.arb + intl_en_US.arb）
- [ ] Step 8: flutter pub run intl_utils:generate
```

## 快速参考索引

### 常用命令速查

| 操作 | 命令 |
|------|------|
| 新增 API / 模型后 | `dart run build_runner build --delete-conflicting-outputs` |
| 新增/修改翻译后 | `flutter pub run intl_utils:generate` |
| 安装依赖 | `flutter pub get` |
| 代码分析 | `flutter analyze` |
| 测试 | `flutter test` |
| Web 运行 | `flutter run -d chrome` |

### Service 文件速查

| 文件 | 对应功能 |
|------|------|
| `account_service.dart` | 账户 CRUD |
| `balance_flow_service.dart` | 流水 CRUD |
| `book_service.dart` | 账本 CRUD |
| `budget_service.dart` | 预算 CRUD |
| `category_service.dart` | 分类 CRUD（树形） |
| `currency_service.dart` | 币种查询 |
| `flow_file_service.dart` | 流水附件 |
| `ledger_auth_service.dart` | 记账认证 |
| `note_day_service.dart` | 定期提醒 CRUD |
| `payee_service.dart` | 收款人 CRUD |
| `report_service.dart` | 统计报表 |
| `tag_service.dart` | 标签 CRUD（树形） |
| `tenant_member_service.dart` | 组员管理 |

### 路由路径速查

| 路径 | 页面 | 说明 |
|------|------|------|
| `/ledger` | LedgerHomePage | 首页（Tab: flows/statistics/accounts/mine） |
| `/ledger/accounts` | AccountListPage | 账户列表 |
| `/ledger/accounts/create` | AccountFormPage | 新建账户 |
| `/ledger/accounts/:id` | AccountFormPage | 编辑账户 |
| `/ledger/accounts/:id/overview` | AccountOverviewPage | 账户概览 |
| `/ledger/flows` | BalanceFlowListPage | 流水列表 |
| `/ledger/flows/create` | BalanceFlowFormPage | 新建流水 |
| `/ledger/categories` | CategoryListPage | 分类列表（树形） |
| `/ledger/tags` | TagListPage | 标签列表（树形） |
| `/ledger/books` | BookListPage | 账本列表 |
| `/ledger/budgets` | BudgetListPage | 预算列表 |
| `/ledger/payees` | PayeeListPage | 收款人列表 |
| `/ledger/notes` | NoteDayListPage | 提醒列表 |
| `/ledger/currencies` | CurrencyListPage | 币种列表 |
| `/ledger/members` | MemberListPage | 成员列表 |
| `/ledger/report` | ReportPage | 统计报表 |
| `/ledger/settings` | SettingsPage | 设置 |
| `/login` | LoginPage | 登录 |
| `/register` | RegisterPage | 注册 |

### 断点常量

| 常量 | 值 | 设备 |
|------|-----|------|
| `Breakpoints.mobile` | < 600 dp | 手机 |
| `Breakpoints.tablet` | 600~1024 dp | 平板 |
| `Breakpoints.web` | > 1024 dp | 桌面/Web |

## 常见错误与纠正

| 错误做法 | 正确做法 |
|---|---|
| 手改 `lib/generated/` | 改源（proto / ARB）后重新生成 |
| Service 不继承 `BaseService` | 继承并用 `handleDioError` 处理错误 |
| 手动拼接分页 query 字符串 | 用 `PaginationQuery` 封装 |
| 一个 build 方法混用 mobile/web | 用 `ResponsiveLayout` 双视图 |
| Web 端用 `.w` / `.h` / `.sp` | Web 端用固定值（手机端才用 ScreenUtil） |
| 硬编码屏宽数值 | 用 `Breakpoints` 常量 |
| 直接访问嵌套翻译字段 | 用 `translation_helpers.dart` 辅助函数 |
| Web 端 SliverToBoxAdapter 嵌套 GridView | 用 `LayoutBuilder` + `Row` / `Column` |
| 返回按钮不检查 canPop | 用 `AppBackButton` 组件 |
| 路由路径硬编码 | 集中管理在 `router_paths.dart` |
| API 调用不 try/catch | 必须捕获 `DioException` 并调用 `handleDioError` |
| ApiClient 手动 new | 从 GetIt 获取：`GetIt.instance<ApiClient>()` |

## FAQ

<details>
<summary><b>Dio 请求报错怎么处理？</b></summary>

所有 Service 继承 `BaseService`，在 `try/catch` 中捕获 `DioException` 并调用 `handleDioError(e)`。该方法会自动提取服务端错误消息并转为用户友好的格式。

```dart
try {
  return await _api.list(...);
} on DioException catch (e) {
  throw handleDioError(e);
}
```
</details>

<details>
<summary><b>怎么添加新的记账功能模块？</b></summary>

完整流程见上方 [新增业务模块 Checklist](#新增业务模块-checklist)。核心步骤：Service → List Page → Form Page → 路由注册 → 导航入口 → i18n。
</details>

<details>
<summary><b>分页怎么实现？</b></summary>

使用 `PaginationQuery` 封装分页参数：

```dart
final query = PaginationQuery(page: 1, pageSize: 20);
final resp = await accountService.list(query);
// 判断是否有更多：resp.items.length >= pageSize
```
</details>

<details>
<summary><b>Web 端和手机端布局有什么区别？</b></summary>

- **手机端**：底部导航栏（LedgerBottomNav），单栏布局，可用 ScreenUtil 的 `.w` / `.h` / `.sp`
- **Web 端**：顶部导航栏（WebShellLayout），居中布局，禁止用 `.w` / `.h` / `.sp`（ScreenUtil designSize 已设为视窗尺寸）
- 用 `ResponsiveLayout(mobileBody: ..., webBody: ...)` 区分
</details>

<details>
<summary><b>路由跳转用 go() 还是 push()？</b></summary>

- `context.go(path)` — 顶级页面切换（替换整个导航栈），如 Tab 切换
- `context.push(path)` — 子页面压栈，如打开表单/详情页
- 返回上一页用 `AppBackButton` 组件（内置 `canPop` 检查）
</details>

<details>
<summary><b>新增翻译文本的流程？</b></summary>

1. 编辑 `lib/l10n/intl_zh_CN.arb` 和 `intl_en_US.arb`，添加新 key
2. 运行 `flutter pub run intl_utils:generate`
3. 代码中通过 `S.of(context).yourNewKey` 使用
4. 带参数：`S.of(context).postsCount(5)`（ARB 中定义 `{count}` 占位符）
</details>

<details>
<summary><b>怎么切换后端 API 地址？</b></summary>

编辑 `.dev.env`（开发环境）或 `.env`（生产环境）中的 `API_BASE_URL`，重启应用即可。

```env
API_BASE_URL="https://api.gowind.cloud"
```
</details>

## Web 端特殊注意事项

- **GridView 限制**：避免在 `CustomScrollView` 的 `SliverToBoxAdapter` 中嵌套 `GridView` + `NeverScrollableScrollPhysics`（触发 viewport hitTest null 错误），改用 `LayoutBuilder` + `Row`/`Column`
- **嵌套 Scaffold**：Web 端 `ShellRoute` 已提供外层 Scaffold，顶级页面需注意滚动冲突
- **导航栏**：Web 端 `WebShellLayout` 提供持久化顶部导航栏，页面无需再显示 AppBar
