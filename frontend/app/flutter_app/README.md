# GoWind Ledger Flutter App

基于 **Flutter** 的全平台个人/家庭记账应用，一套 Dart 代码编译为 iOS / Android / Web / macOS / Windows / Linux。

## 核心功能

| 模块 | 说明 |
|------|------|
| 账户 | 账户 CRUD、余额调整、资产概览（总资产/总负债/净资产） |
| 流水 | 收支流水 CRUD、附件管理、按账本/分类/标签过滤 |
| 账本 | 多账本管理、账本模板 |
| 预算 | 预算 CRUD、周期预算进度（月/季/年/周） |
| 分类 | 树形分类 CRUD |
| 标签 | 树形标签 CRUD |
| 收款人 | 收款人 CRUD |
| 提醒 | 定期提醒 CRUD |
| 币种 | 币种查询 |
| 成员 | 租户成员管理 |
| 报表 | 统计报表 |
| 设置 | 主题模式/主题色/语言切换、默认账本/租户、登出 |

## 技术栈

Flutter 3.x (Dart 3.12+) · flutter_bloc/Cubit（状态管理） · GoRouter（路由） · GetIt（IoC） · Dio + protoc-gen-dart-http（HTTP + API 生成） · flutter_intl（i18n） · Material 3

**代码生成工具链**：protoc-gen-dart-http（API client）+ intl_utils（i18n）+ build_runner + freezed + json_serializable

## 快速开始

```bash
# 1. 安装依赖
flutter pub get

# 2. 生成 i18n（编辑 lib/l10n/*.arb 后必须执行）
flutter pub run intl_utils:generate

# 3. 生成 API/模型代码（proto 变更后必须执行）
dart run build_runner build --delete-conflicting-outputs

# 4. 运行
flutter run -d chrome          # Web 开发
flutter run -d ios / android   # 移动端开发
```

**环境变量**（`.dev.env` Debug / `.env` Release，通过 flutter_dotenv 加载）：

```env
API_BASE_URL="https://api.gowind.cloud"
SSE_URL="https://sse.gowind.cloud/events"
CONNECTION_TIMEOUT=3000
RECEIVE_TIMEOUT=3000
AES_KEY="f51d66a73d8a0927"
```

## 项目结构

```
flutter_app/
├── lib/
│   ├── main.dart                      # 入口（init + MultiBlocProvider）
│   ├── src/
│   │   ├── app.dart                   # MaterialApp.router
│   │   ├── init.dart                  # 应用初始化（ApiClient / Dio / 仓库注册）
│   │   ├── app_router/                # GoRouter 路由配置 + 路由名称常量
│   │   ├── core/                      # 基础设施（config / transport / services / themes / preference）
│   │   └── features/
│   │       ├── auth/                  # 认证模块（登录 / 注册）
│   │       └── ledger/                # 记账核心（22 页 + 13 服务 + 4 组件）
│   ├── generated/                     # [自动生成] l10n.dart + api/
│   └── l10n/                          # ARB 翻译文件（intl_zh_CN / intl_en_US）
├── assets/                            # 图片/字体资源
├── test/                              # 测试
├── pubspec.yaml
└── .dev.env / .env                    # 环境变量
```

## 文档

| 文档 | 说明 |
|------|------|
| [AGENTS.md](./AGENTS.md) | **编码规范单一事实源** — 架构、约定、分层模板、Checklist |
| [docs/api-guide.md](./docs/api-guide.md) | API 层开发指南 — 生成流程、Service 规范、分页、主题管理 |
| [SKILL.md](./SKILL.md) | 可复用技能 — 新增功能模块、i18n、API 诊断、响应式布局、主题 |

## 开发命令备忘

### Flutter 常用命令

- `flutter doctor` 查看环境配置状态
- `flutter pub get` 下载依赖库
- `flutter pub run intl_utils:generate` 生成 i18n 代码
- `dart run build_runner build --delete-conflicting-outputs` 生成 API/模型代码
- `flutter run` 运行项目（默认 `--debug`）
- `flutter build web / apk / ios / macos / windows` 构建生产产物
- `flutter analyze` 代码分析
- `flutter test` 单元测试
- `flutter clean` 清除构建缓存

### Pod 命令（iOS）

- `pod install` 根据 `Podfile` 拉取依赖库（首次执行自动创建 `Podfile.lock`）
- `pod install --repo-update` 拉取前更新本地 spec 仓库
- `pod update` 更新 `Podfile.lock` 中的三方库版本
- `pod repo update` 更新本地 spec 仓库

## Intl 插件

```bash
flutter pub run intl_utils:generate
```

或者全局安装：

```bash
flutter pub global activate intl_utils
dart pub global run intl_utils:generate
```

## proto 插件

安装和更新 `protoc-gen-dart` 插件：

```bash
flutter pub global activate protoc_plugin
```
