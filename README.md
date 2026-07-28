<div align="center">

# GoWind Ledger

### 风行记账 · 开箱即用的个人/家庭全栈记账平台

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.25+-00ADD8?logo=go&logoColor=white)](https://go.dev/)
[![Vue](https://img.shields.io/badge/Vue-3.x-4FC08D?logo=vue.js&logoColor=white)](https://vuejs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Kratos](https://img.shields.io/badge/Kratos-2.9-00ADD8?logo=go&logoColor=white)](https://go-kratos.dev/)
[![Ent](https://img.shields.io/badge/Ent-0.14-00ADD8?logo=go&logoColor=white)](https://entgo.io/)

**[English](./README.en-US.md)** · **中文** · **[日本語](./README.ja-JP.md)**

</div>

---

风行记账（GoWind Ledger）是一款基于 Go 微服务架构的全栈个人/家庭记账平台，提供完整的收支管理、多账户管理、分类标签体系、多币种汇率、统计报表与定期提醒功能，支持 Admin 管理后台和 Flutter 跨平台移动应用。

**核心亮点：**

- **记账核心** — 支出/收入/转账/余额调整四种流水类型，单式记账引擎，分类/标签金额拆分
- **多账户管理** — 活期/信用/资产/贷款四类账户，余额自动更新，支持跨币种转账
- **层级分类** — 支出/收入分类支持 4 层树形结构，标签支持能力标志（可支出/收入/转账）
- **多币种** — 内置 10 种币种汇率缓存，支持实时汇率刷新与货币转换计算
- **统计报表** — 按分类/标签/收款人维度聚合分析，资产负债概览，ECharts 可视化
- **定期提醒** — 按每天/每月/每年重复提醒，支持执行与撤回操作
- **微服务架构** — 基于 go-kratos，Admin BFF + App BFF + Core 三服务架构
- **API 优先** — Protobuf 合约驱动，RESTful + gRPC 双协议，OpenAPI 文档自动生成

## 系统架构

```
┌─────────────────────────────────────────────────────────┐
│                    客户端层                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  Admin 后台  │  │  Flutter App │  │   Swagger    │    │
│  │  Vue3+AntDV  │  │  BLoC+Dio    │  │   /docs/     │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
└─────────┼────────────────┼────────────────┼────────────┘
          │ REST :6600     │ REST :6700     │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────┐
│                  BFF 网关层                               │
│  ┌─────────────┐         ┌─────────────┐               │
│  │ Admin BFF   │         │  App BFF    │               │
│  │ /admin/v1/* │         │  /app/v1/*  │               │
│  └──────┬──────┘         └──────┬──────┘               │
└─────────┼───────────────────────┼──────────────────────┘
          │ gRPC                  │ gRPC
          ▼                       ▼
┌─────────────────────────────────────────────────────────┐
│                  Core 核心服务                             │
│  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐   │
│  │ Book  │ │Account│ │ Flow  │ │Report │ │Currency│  │
│  └───────┘ └───────┘ └───────┘ └───────┘ └───────┘   │
│  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐   │
│  │Category│ │  Tag  │ │Payee  │ │NoteDay│ │FlowFile│  │
│  └───────┘ └───────┘ └───────┘ └───────┘ └───────┘   │
│         │ Ent ORM → PostgreSQL                          │
│         │ Redis · MinIO · etcd                          │
└─────────┴──────────────────────────────────────────────┘
```

## 技术栈

### 后端

| 层级     | 技术                                                                 | 说明            |
|:-------|:-------------------------------------------------------------------|:--------------|
| 语言     | [Go 1.25+](https://go.dev/)                                        | 高性能编译型语言      |
| 框架     | [go-kratos](https://go-kratos.dev/)                                | B 站开源微服务框架    |
| 依赖注入   | [Wire](https://github.com/google/wire)                             | 编译时依赖注入       |
| ORM    | [Ent](https://entgo.io/)                                           | Go 实体框架       |
| 数据库    | [PostgreSQL](https://www.postgresql.org/) / [MySQL](https://www.mysql.com/) | 关系型数据库 |
| 缓存     | [Redis](https://redis.io/)                                         | 内存数据库         |
| 对象存储   | [MinIO](https://min.io/)                                           | 兼容 S3 的对象存储   |
| 服务注册   | [Etcd](https://etcd.io/)                                           | 服务发现与配置       |
| 链路追踪   | [Jaeger](https://www.jaegertracing.io/) + [OpenTelemetry](https://opentelemetry.io/) | 分布式可观测 |
| API 定义 | [Protobuf](https://protobuf.dev/) + [buf.build](https://buf.build/) | 接口契约优先        |
| 权限引擎   | [Casbin](https://casbin.org/) / [OPA](https://www.openpolicyagent.org/) | 策略驱动鉴权     |

### Admin 管理后台

| 技术                                            | 说明           |
|:----------------------------------------------|:-------------|
| [Vue 3](https://vuejs.org/)                   | 渐进式前端框架      |
| [TypeScript](https://www.typescriptlang.org/) | 类型安全         |
| [Ant Design Vue](https://antdv.com/)          | 企业级 UI 组件库   |
| [Vben Admin](https://doc.vben.pro/)           | 后台管理框架       |
| [Vxe Table](https://vxetable.cn/)            | 高性能表格组件      |
| [ECharts](https://echarts.apache.org/)        | 数据可视化        |

### 移动端应用

| 技术                                            | 说明           |
|:----------------------------------------------|:-------------|
| [Flutter](https://flutter.dev/)               | 跨平台原生应用框架    |
| [BLoC](https://bloclibrary.dev/)              | 状态管理         |
| [go_router](https://pub.dev/packages/go_router) | 声明式路由      |
| [Dio](https://pub.dev/packages/dio)           | HTTP 客户端     |
| [cached_query](https://pub.dev/packages/cached_query) | 数据缓存与查询 |

## 核心功能

### 记账引擎

| 功能     | 说明                                                    |
|:-------|:------------------------------------------------------|
| 收支流水   | 支出/收入/转账/余额调整四种类型，分类金额拆分，标签关联，附件管理                   |
| 余额确认   | 流水确认后自动更新账户余额，删除时自动回滚，保证资金一致性                        |
| 统计分析   | 按分类/标签/收款人维度聚合分析，支出/收入/净额统计，资产负债概览                  |
| 跨币种转账  | 转账时自动计算换算金额，支持多币种账户间的资金流转                           |

### 账户与账本

| 功能     | 说明                                                    |
|:-------|:------------------------------------------------------|
| 账本管理   | 多租户账本，默认账户/分类配置，启用/禁用切换                              |
| 账户管理   | 活期/信用/资产/贷款四类账户，能力标志（可支出/收入/转出/转入），余额调整            |
| 余额调整   | 余额调整时自动创建 ADJUST 流水记录，保留调整审计轨迹                      |
| 币种管理   | 内置 10 种币种汇率缓存，支持刷新汇率与货币转换计算                          |

### 分类体系

| 功能     | 说明                                                    |
|:-------|:------------------------------------------------------|
| 层级分类   | 支出/收入分类支持 4 层树形结构，按账本隔离                             |
| 层级标签   | 标签支持树形结构，能力标志（可支出/收入/转账）                            |
| 收款人管理  | 按账本隔离的收款人/付款人管理，能力标志控制                              |
| 定期提醒   | 按每天/每月/每年重复提醒，支持执行与撤回操作                             |

### 权限与安全

| 功能     | 说明                                                    |
|:-------|:------------------------------------------------------|
| 多租户隔离  | 所有记账数据按租户隔离，基于 ent TenantID mixin                   |
| JWT 认证  | HS256 JWT 令牌，Admin/App 双认证配置                         |
| RBAC 授权 | Casbin/OPA 策略引擎，菜单/接口/数据三级权限管控                     |
| 审计日志   | API 审计、登录审计、操作审计、数据访问审计、权限审计                       |

## 项目结构

```
go-wind-ledger/
├── backend/                     # 后端微服务
│   ├── api/                     # Proto 合约 + 生成代码
│   │   ├── protos/              # Proto 源文件
│   │   │   ├── ledger/          # 记账领域模型（10 个 proto）
│   │   │   ├── admin/           # Admin BFF 接口（i_ 前缀）
│   │   │   └── app/             # App BFF 接口（i_ 前缀）
│   │   └── gen/go/              # 生成的 Go 代码
│   ├── app/                     # 微服务应用
│   │   ├── admin/service/       # Admin BFF 网关（REST :6600）
│   │   ├── app/service/         # App BFF 网关（REST :6700）
│   │   └── core/service/        # Core 核心服务（gRPC）
│   ├── pkg/                     # 跨服务共享库
│   └── sql/                     # 数据库种子数据
├── frontend/                    # 前端应用
│   ├── admin/                   # Admin 管理后台（Vue3 + Vben Admin）
│   │   └── apps/admin/src/
│   │       ├── api/composables/ # 10 个记账 composables
│   │       ├── views/app/ledger/ # 9 个记账模块页面
│   │       └── router/          # 自动加载路由
│   └── app/
│       └── flutter_app/         # Flutter 移动端
│           └── lib/src/features/ledger/
│               ├── services/    # 9 个记账服务
│               ├── pages/       # 17 个记账页面
│               └── widgets/     # 4 个通用组件
└── docker-compose.yaml          # 基础设施编排
```

## 快速开始

### 环境要求

- Go 1.25+
- Node.js 20+ / pnpm 9+
- Flutter 3.12+ / Dart 3.12+
- Docker & Docker Compose
- PostgreSQL 15+ / Redis 7+ / MinIO / etcd

### 1. 启动基础设施

```bash
cd backend
docker-compose up -d postgres redis minio etcd
```

### 2. 启动后端服务

```bash
cd backend
make compose-up-libs    # 启动基础设施
make run                # 运行所有服务
```

### 3. 启动 Admin 管理后台

```bash
cd frontend/admin
pnpm install
pnpm dev
```

### 4. 启动 Flutter 移动端

```bash
cd frontend/app/flutter_app
flutter pub get
flutter run
```

## 开发命令

| 命令                | 说明                          |
|:------------------|:----------------------------|
| `make gen`        | 全量代码生成（ent + wire + api + openapi） |
| `make api`        | Proto → Go 代码生成             |
| `make ent`        | Ent ORM 代码生成                |
| `make wire`       | Wire 依赖注入代码生成               |
| `make build`      | 编译所有服务                     |
| `make run`        | 运行所有服务                     |
| `make compose-up` | Docker Compose 启动全部         |

## 开源协议

[MIT License](./LICENSE)
