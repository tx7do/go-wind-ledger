# Skills: Flutter Mobile Development

> 本文件定义 Flutter 记账应用开发中常用的可复用技能/工作流，供 AI 编码工具调用。

---

## skill: add-ledger-feature

**描述**: 在 Flutter 记账应用中新增一个完整的业务功能模块（Service + List Page + Form Page + 路由）。

**前置条件**: 后端 API 已就绪，`lib/generated/api/` 中已有对应的 `XxxServiceClient`。

### 步骤

```
Step 1: 确认 API 客户端已生成
  dart run build_runner build --delete-conflicting-outputs
  确认 lib/generated/api/app/service/v1/ 中存在对应类型

Step 2: 创建 Service
  在 lib/src/features/ledger/services/xxx_service.dart
  继承 BaseService → 通过 GetIt.instance<ApiClient>().xxxService 获取 API client
  实现 list / get / create / update / delete 方法
  每个方法用 try/catch + handleDioError
  模板见 frontend/app/flutter_app/AGENTS.md 的 "Service 层模板" 章节

Step 3: 创建列表页
  在 lib/src/features/ledger/pages/xxx_list_page.dart
  StatefulWidget + ResponsiveLayout + PaginationQuery 分页
  模板见 AGENTS.md 的 "列表页模板" 章节

Step 4: 创建表单页
  在 lib/src/features/ledger/pages/xxx_form_page.dart
  通过 id 参数区分新建/编辑模式
  Form + TextFormField + AppBar actions 提交按钮
  模板见 AGENTS.md 的 "表单页模板" 章节

Step 5: 注册路由
  在 app_router.dart 中添加 GoRoute（含 list / create / :id）
  在 route_names.dart 中添加名称常量
  在 router_paths.dart 中添加路径常量

Step 6: 添加导航入口
  如在首页 LedgerBottomNav 添加 Tab
  或从相关页面添加跳转按钮

Step 7: 添加 i18n
  在 lib/l10n/intl_zh_CN.arb 和 intl_en_US.arb 添加文本 key
  运行 flutter pub run intl_utils:generate

Step 8: 代码分析
  flutter analyze
```

### 关键检查点

- Service 必须继承 `BaseService`
- API 调用必须 try/catch 捕获 `DioException`
- 响应式布局用 `ResponsiveLayout(mobileBody:, webBody:)`
- Web 端禁止用 `.w` / `.h` / `.sp`
- 路由跳转：顶级切换 `context.go()`，子页 `context.push()`
- 返回按钮用 `AppBackButton`

---

## skill: add-i18n

**描述**: 为 Flutter 应用添加新的国际化文本或新语言支持。

### 添加新文本

```
Step 1: 编辑 ARB 文件
  在 lib/l10n/intl_zh_CN.arb 添加 key（中文）
  在 lib/l10n/intl_en_US.arb 添加相同 key（英文）
  如需参数：使用 {paramName} 占位符

Step 2: 重新生成
  flutter pub run intl_utils:generate

Step 3: 使用
  Text(S.of(context).yourNewKey)
  Text(S.of(context).postsCount(5))  // 带参数
```

### 添加新语言（以日语为例）

```
Step 1: 复制翻译文件
  创建 lib/l10n/intl_ja_JP.arb（复制 intl_en_US.arb 并翻译）

Step 2: 注册语言
  在 pubspec.yaml 的 flutter_intl 配置中添加 ja_JP

Step 3: 添加语言标签
  在 settings_page.dart 的 localeLabels 添加日语选项

Step 4: 重新生成
  flutter pub run intl_utils:generate
```

---

## skill: fix-api-error

**描述**: Flutter 应用中的 API 调用错误诊断流程。

### 常见错误与解决

| 症状 | 诊断 | 解决 |
|------|------|------|
| DioException: Connection refused | 后端服务未启动或地址错误 | 检查 `.dev.env` 的 `API_BASE_URL` |
| DioException: 401 Unauthorized | Token 过期或未登录 | 检查 Token 注入拦截器；重新登录 |
| type 'Null' is not a subtype | API 返回 null 但类型声明非空 | 添加 `?` 可空标记；或后端修复 |
| NoSuchMethodError | API client 方法不存在 | 重新生成 API 代码：`dart run build_runner build` |
| MissingPluginException | 原生插件在 Web 端不可用 | 添加平台判断：`if (!kIsWeb) { ... }` |

### 调试流程

```
1. 查看 Dio 拦截器日志（查看实际请求 URL 和响应）
2. 用 Swagger UI (http://localhost:6700/docs/) 验证 API 是否正常
3. 对比 Service 层的参数和 proto 定义是否一致
4. 确认 ApiClient 从 GetIt 正确注入：GetIt.instance<ApiClient>()
```

---

## skill: add-responsive-layout

**描述**: 为新页面添加响应式布局（移动端 + Web 端双视图）。

### 模板

```dart
import 'package:flutter/material.dart';

import 'package:flutter_app/src/core/widgets/responsive_layout.dart';
import 'package:flutter_app/src/core/utils/responsive_utils.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileView(context),
      webBody: _buildWebView(context),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: /* 单栏布局 */,
    );
  }

  Widget _buildWebView(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: /* 居中布局 */,
        ),
      ),
    );
  }
}
```

### 关键规则

- 手机端：用 `Scaffold` + `AppBar` + 底部 `LedgerBottomNav`（首页）
- Web 端：不设置 `AppBar`（WebShellLayout 提供全局导航栏），内容 `Center` + `ConstrainedBox(maxWidth: 800)`
- 禁止在 Web 端使用 `.w` / `.h` / `.sp`
