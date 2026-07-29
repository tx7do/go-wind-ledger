# AGENTS.md — 后端开发指南

> 本文件是 backend 子项目的 AI 编码规范单一事实源，适用于所有支持 AGENTS.md 的 AI 编码工具（ZCode、GitHub Copilot、Cursor、Codex、Gemini CLI 等）。Claude Code 通过同级 `CLAUDE.md` 中的 `@AGENTS.md` 引用加载。

## 目录

- [项目概览](#项目概览)
- [三服务架构（关键心智模型）](#三服务架构关键心智模型)
- [目录结构](#目录结构)
- [api 层组织（proto-first）](#api-层组织proto-first)
- [关键约定（必须遵守）](#关键约定必须遵守)
- [错误处理详解](#错误处理详解)
- [分层架构模板](#分层架构模板)
- [依赖注入（google/wire）](#依赖注入googlewire)
- [日志](#日志)
- [配置管理](#配置管理)
- [数据库迁移](#数据库迁移)
- [请求校验（双轨制）](#请求校验双轨制)
- [中间件](#中间件)
- [国际化（i18n）](#国际化i18n)
- [构建与开发命令](#构建与开发命令)
- [Swagger / API 文档](#swagger--api-文档)
- [新增业务模块 Checklist](#新增业务模块-checklist以-user-模块为模板)
- [快速参考索引](#快速参考索引)
- [常见错误与纠正](#常见错误与纠正)
- [FAQ](#faq)
- [关键文件索引](#关键文件索引)

## 项目概览

基于 [go-kratos v2](https://github.com/go-kratos/kratos) 微服务框架的多租户记账与内容管理平台，采用 **Protobuf-first（契约驱动）** 工作流。

**核心技术栈**：
- **框架**: go-kratos v2.9.2（HTTP + gRPC + SSE）
- **语言**: Go 1.25
- **ORM**: entgo.io/ent v0.14（schema 即代码，启用 privacy/entql/upsert 等特性）
- **依赖注入**: google/wire（编译期代码生成）
- **数据库**: PostgreSQL（主）/ MySQL，驱动 pgx/v5
- **缓存/队列**: Redis（go-redis/v9）、Asynq 异步任务
- **鉴权**: kratos-authn（JWT HS256）+ kratos-authz（Casbin / OPA）
- **存储**: MinIO（S3 兼容）
- **搜索**: ElasticSearch / OpenSearch
- **服务发现**: etcd
- **可观测性**: OpenTelemetry + Jaeger
- **分布式事务**: DTM
- **日志**: zap / logrus（经 kratos-bootstrap 封装为 `log.Helper`）

**基础设施全家桶**: 大量依赖 `tx7do` 系列库（go-utils / go-crud / kratos-bootstrap / kratos-transport / kratos-authn/authz），是项目基建主力。修改这些集成点时需先理解其封装。

## 三服务架构（关键心智模型）

```
HTTP/REST 请求
  └─ admin-service  (网关 BFF，REST:6600 / SSE:6601 / gRPC)
       └─ gRPC → core-service  (核心业务 + 数据落点)
                 ├─ ent ORM → PostgreSQL
                 ├─ Redis / MinIO / ElasticSearch
                 └─ DTM / Asynq

app-service (前台 BFF，REST:6700) ──gRPC──→ core-service
core-service (gRPC，真正干活)
```

| 服务 | 角色 | 是否访问 DB |
|------|------|:---:|
| `app/admin/service` | 后台网关 BFF（接收 REST，转发 gRPC 到 core） | ❌ |
| `app/app/service` | 前台网关 BFF | ❌ |
| `app/core/service` | 核心业务实现（持久化、真实逻辑） | ✅ |

> **admin / app 服务是"瘦"网关**：它们的 service 仅做参数校验 + gRPC 转发到 core。**所有数据库操作只能在 core-service 内进行。**

## 目录结构

```
backend/
├── api/                          # 接口契约层（proto 源 + 生成代码，无业务逻辑）
│   ├── protos/                   # ★ proto 源文件（人工维护，11 个领域）
│   │   └── <domain>/service/v1/  # 按领域组织：admin/app/identity/permission/content/audit/...
│   └── gen/go/                   # ← protoc 生成（禁止手改）
├── app/                          # 应用实现层（3 个独立微服务）
│   └── <admin|app|core>/service/
│       ├── cmd/server/           # 入口 + wire 注入
│       │   ├── main.go
│       │   ├── wire.go           # wireinject 声明
│       │   └── wire_gen.go       # ← wire 生成（禁止手改）
│       ├── configs/              # 运行时配置（server/data/client/...yaml）
│       └── internal/
│           ├── server/           # 传输层（HTTP/gRPC/SSE 装配 + 中间件）
│           ├── service/          # 业务逻辑层（实现 proto 接口）
│           │   └── providers/wire_set.go
│           └── data/             # 数据访问层（仅 core 服务有 DB）
│               ├── ent/schema/   # ★ ent 实体定义（人工维护，50 个 schema）
│               ├── ent/          # ← ent generate 生成（禁止手改）
│               ├── *_repo.go     # 仓储实现
│               └── providers/wire_set.go
├── pkg/                          # 跨服务公共库（中间件/加密/工具/领域包，16 个包）
├── sql/                          # 数据库种子/演示数据脚本
├── scripts/                      # 部署与环境脚本（env/docker/deploy）
├── Makefile / app.mk             # 构建编排
└── go.mod
```

## api 层组织（proto-first）

`api/` 按 **领域(domain) → service → version** 三级组织，严格区分源码与生成代码：

```
api/
├── protos/                       # ★ 人工维护的 proto 源（11 个领域）
│   └── admin/service/v1/i_user.proto       # BFF 对外接口（带 google.api.http 注解）
│   └── identity/service/v1/user.proto      # 核心服务接口（gRPC + message 定义）
│   └── identity/service/v1/user_error.proto# 错误码定义
└── gen/go/                       # ← protoc 生成（禁止手改）
    └── identity/service/v1/
        ├── user.pb.go                      # message
        ├── user.pb.validate.go             # protoc-gen-validate
        ├── user_grpc.pb.go                 # gRPC stub
        └── user_http.pb.go                 # Kratos HTTP stub
```

**proto 命名约定**：
- BFF 域（admin/app）的文件以 `i_` 前缀（如 `i_user.proto`），定义对外 REST 接口
- 核心域（identity/permission/content 等）用 `{entity}.proto`，定义 gRPC 接口与实体 message
- 包名 `{domain}.service.v1`（如 `identity.service.v1`）
- **BFF proto 复用核心域 message**：admin 的 `i_user.proto` 通过 `import "identity/service/v1/user.proto"` 复用，不重复定义实体

## 关键约定（必须遵守）

### 契约与生成

1. **Protobuf 是单一事实源** — 所有接口、数据模型、错误码必须先在 `api/protos/` 定义，再生成 Go 代码
2. **禁止手改生成代码** — `api/gen/`、`*/ent/`（除 `ent/schema/`）、`wire_gen.go` 均为生成产物
3. **改 proto 后必须重新生成** — 执行 `make api`（或一键 `make gen`）
4. **新增 ent 实体后必须重新生成** — 执行 `make ent`
5. **新增/修改构造函数后必须重新生成** — 执行 `make wire`

### 分层规约

6. **admin/app service 不碰数据库** — 它们只校验参数并 gRPC 转发到 core
7. **数据访问只在 core-service 的 `internal/data/`** — 其它服务不直接操作 ent
8. **每层有独立的 `providers/wire_set.go`** — 新增构造函数必须注册到对应层的 ProviderSet

### 命名约定

9. **文件**：`snake_case.go`，按 `<entity>_service.go` / `<entity>_repo.go` 划分
10. **结构体**：导出 `PascalCase`（`UserService`）；未导出实现小写首字母（`userRepo`）
11. **接口与实现分离**：接口大写 `UserRepo`，实现小写 `userRepo`，构造函数 `NewUserRepo(...) UserRepo` **返回接口类型**
12. **构造函数统一 `NewXxx` 前缀**（`NewUserService`、`NewEntClient`）
13. **接收者简短**：service 用 `s`，repo 用 `r`，context 用 `ctx`（`func (s *UserService)`、`func (r *userRepo)`）
14. **包名全小写**，与目录一致（`package service`、`package data`、`package schema`）

### 错误处理

15. **统一使用 Kratos 错误码封装** — 错误在 `*_error.proto` 中用 enum 定义并生成 `ErrorXxx` 助手函数
16. **禁止裸用 `errors.New` / `fmt.Errorf`** — 业务错误用生成的 `identityV1.ErrorBadRequest("invalid parameter")`、`identityV1.ErrorNotFound("user not found")` 等

## 错误处理详解

**三步流程**：

1. 在 `api/protos/<domain>/service/v1/*_error.proto` 定义错误原因与 HTTP 状态码：

```proto
enum IdentityErrorReason {
  option (errors.default_code) = 500;
  BAD_REQUEST = 0 [(errors.code) = 400];
  UNAUTHORIZED = 100 [(errors.code) = 401];
  NOT_FOUND = 400 [(errors.code) = 404];
  USER_NOT_FOUND = 401 [(errors.code) = 404];
  INTERNAL_SERVER_ERROR = 2000 [(errors.code) = 500];
}
```

2. `make api` 生成便利函数：

```go
func ErrorBadRequest(format string, args ...interface{}) *errors.Error { ... }
func IsBadRequest(err error) bool { ... }
```

3. 业务代码调用（**唯一允许的错误返回方式**）：

```go
return nil, identityV1.ErrorBadRequest("invalid parameter")
return nil, identityV1.ErrorNotFound("user not found")
return nil, identityV1.ErrorInternalServerError("insert user failed")
```

中间件层自定义错误用 `kratos/v2/errors` 直接构造：

```go
var ErrMissingBearerToken = errors.Unauthorized("UNAUTHORIZED", "missing bearer token")
```

## 分层架构模板

### server 层（传输 + 路由注册）

路由**不手写**，由 proto 生成的 `RegisterXxxHTTPServer` 函数在 `rest_server.go` 中组装：

```go
func NewRestServer(
    ctx *bootstrap.Context,
    middlewares []middleware.Middleware,
    userService *service.UserService,
    roleService *service.RoleService,
    // ... 其它 service 依赖注入
) *http.Server {
    srv, err := rpc.CreateRestServer(ctx, middlewares...)
    // ...
    adminV1.RegisterUserServiceHTTPServer(srv, userService)   // proto 生成的注册函数
    adminV1.RegisterRoleServiceHTTPServer(srv, roleService)
    return srv
}
```

### service 层（业务逻辑）

**网关层（admin/app）—— 薄转发**：

```go
type UserService struct {
    adminV1.UserServiceHTTPServer              // 嵌入 proto 生成的接口
    log  *log.Helper
    userServiceClient identityV1.UserServiceClient   // gRPC client，注入
}

func NewUserService(ctx *bootstrap.Context, userServiceClient identityV1.UserServiceClient) *UserService {
    svc := &UserService{
        log: ctx.NewLoggerHelper("user/service/admin-service"),
        userServiceClient: userServiceClient,
    }
    svc.init()
    return svc
}

func (s *UserService) Create(ctx context.Context, req *identityV1.CreateUserRequest) (*identityV1.User, error) {
    if req == nil || req.Data == nil {
        return nil, adminV1.ErrorBadRequest("invalid request")
    }
    operator, err := auth.FromContext(ctx)        // 从上下文取操作者
    if err != nil {
        return nil, err
    }
    req.Data.CreatedBy = trans.Ptr(operator.GetUserId())
    return s.userServiceClient.Create(ctx, req)   // 转发到 core
}
```

**核心层（core）—— 真实业务**：

```go
type UserService struct {
    identityV1.UnimplementedUserServiceServer    // 嵌入 proto 生成的 gRPC server 接口
    log *log.Helper
    userRepo data.UserRepo                       // 依赖 repo（接口）
}

func NewUserService(ctx *bootstrap.Context, userRepo data.UserRepo) *UserService {
    svc := &UserService{
        log: ctx.NewLoggerHelper("user/service/core-service"),
        userRepo: userRepo,
    }
    svc.init()
    return svc
}

func (s *UserService) List(ctx context.Context, req *paginationV1.PagingRequest) (*identityV1.ListUserResponse, error) {
    if req == nil {
        s.log.Errorf("invalid parameter: nil request")
        return nil, identityV1.ErrorBadRequest("invalid parameter")
    }
    resp, err := s.userRepo.List(ctx, req)
    if err != nil {
        s.log.Errorf("userRepo.List failed: %s", err.Error())
        return nil, err
    }
    return resp, nil
}
```

### repository / data 层（数据库操作）

每个实体一个 `*_repo.go`，基于 ent + `tx7do/go-crud/entgo` 通用仓储。**事务统一用 defer 闭包模式**：

```go
type UserRepo interface {                                    // 接口定义在最上
    List(ctx context.Context, req *paginationV1.PagingRequest) (*identityV1.ListUserResponse, error)
    Get(ctx context.Context, req *identityV1.GetUserRequest) (*identityV1.User, error)
    Create(ctx context.Context, req *identityV1.CreateUserRequest) (*identityV1.User, error)
}

type userRepo struct {                                       // 实现小写
    entClient *entCrud.EntClient[*ent.Client]
    log       *log.Helper
}

func NewUserRepo(...) UserRepo {                             // 构造返回接口
    repo := &userRepo{ ... }
    repo.init()
    return repo
}

func (r *userRepo) Create(ctx context.Context, req *identityV1.CreateUserRequest) (dto *identityV1.User, err error) {
    if req == nil || req.Data == nil {
        return nil, identityV1.ErrorBadRequest("invalid parameter")
    }
    var tx *ent.Tx
    tx, err = r.entClient.Client().Tx(ctx)                   // 开启事务
    if err != nil {
        return nil, identityV1.ErrorInternalServerError("start transaction failed")
    }
    defer func() {                                            // ★ 标准化 defer 事务模式
        if err != nil {
            if rbErr := tx.Rollback(); rbErr != nil {
                r.log.Errorf("transaction rollback failed: %s", rbErr.Error())
            }
            return
        }
        if cErr := tx.Commit(); cErr != nil {
            r.log.Errorf("transaction commit failed: %s", cErr.Error())
            err = identityV1.ErrorInternalServerError("transaction commit failed")
        }
    }()
    return r.CreateWithTx(ctx, tx, req.GetData())            // 事务内执行
}
```

查询用 ent builder：

```go
func (r *userRepo) Get(ctx context.Context, req *identityV1.GetUserRequest) (*identityV1.User, error) {
    builder := r.entClient.Client().User.Query()
    var whereCond []func(s *sql.Selector)
    switch req.QueryBy.(type) {                              // proto oneof → 条件
    case *identityV1.GetUserRequest_Id:
        whereCond = append(whereCond, user.IDEQ(req.GetId()))
    case *identityV1.GetUserRequest_Username:
        whereCond = append(whereCond, user.UsernameEQ(req.GetUsername()))
    }
    return r.repository.Get(ctx, builder, req.GetViewMask(), whereCond...)
}
```

> 跨实体关联操作通过调用子 repo 的 `*WithTx` 方法共享同一事务。

### model / entity 层（ent schema）

实体定义在 `app/core/service/internal/data/ent/schema/`（**唯一人工维护的 ent 目录**，共 50 个 schema）：

```go
type User struct{ ent.Schema }

func (User) Annotations() []schema.Annotation {
    return []schema.Annotation{
        entsql.Annotation{Table: "sys_users", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
        schema.Comment("用户表"),
    }
}

func (User) Fields() []ent.Field {
    return []ent.Field{
        field.String("username").Comment("用户名").NotEmpty().Immutable().Optional().Nillable(),
        field.String("email").Comment("电子邮箱").MaxLen(320).Optional().Nillable(),
        field.Enum("status").Comment("状态").Optional().Nillable().Default("NORMAL").
            NamedValues("Normal", "NORMAL", "Disabled", "DISABLED"),
    }
}

func (User) Mixin() []ent.Mixin {                            // 复用 pkg/entgo/mixin 通用 mixin
    return []ent.Mixin{
        mixin.AutoIncrementId{},
        mixin.OperatorID{},                                  // 自动 created_by/updated_by/deleted_by
        mixin.TimeAt{},                                      // 自动 created_at/updated_at
        mixin.TenantID[uint32]{},                            // 多租户字段
    }
}

func (User) Indexes() []ent.Index {
    return []ent.Index{
        index.Fields("tenant_id", "username").Unique().StorageKey("idx_sys_user_tenant_username"),
    }
}
```

> ent 实体（`ent.User`）与 DTO（`identityV1.User` proto message）之间通过 `mapper.CopierMapper` + 枚举 `EnumTypeConverter` 在 repo 层转换。**对外数据模型是 proto message，不是 ent 实体。**

## 依赖注入（google/wire）

编译期代码生成 DI。每层一个 `providers/wire_set.go`（带 `//go:build wireinject` 标签）：

```go
// app/core/service/internal/data/providers/wire_set.go
//go:build wireinject
package providers

import "github.com/google/wire"
import "go-wind-ledger/app/core/service/internal/data"

var ProviderSet = wire.NewSet(
    data.NewRedisClient,
    data.NewEntClient,
    data.NewUserRepo,         // ★ 每个 repo 构造函数都登记
    data.NewRoleRepo,
    // ...
)
```

顶层 `cmd/server/wire.go` 组合各层：

```go
//go:build wireinject
func initApp(*bootstrap.Context) (*kratos.App, func(), error) {
    panic(wire.Build(
        serverProviders.ProviderSet,
        serviceProviders.ProviderSet,
        dataProviders.ProviderSet,
        newApp,
    ))
}
```

> **新增任何构造函数后**：1) 注册到对应层的 `ProviderSet`；2) 执行 `make wire` 重新生成 `wire_gen.go`。

## 日志

使用 Kratos `log.Helper`，通过 `ctx.NewLoggerHelper(moduleName)` 创建带模块标识的 logger：

```go
svc := &UserService{
    log: ctx.NewLoggerHelper("user/service/core-service"),
}

s.log.Errorf("userRepo.List failed: %s", err.Error())
s.log.Debugf("get user id=%d role_ids=%v", dto.GetId(), roleIDs)
```

> **禁止**用 `fmt.Println` / `log.Println`（标准库）做业务日志，统一用注入的 `*log.Helper`。

## 配置管理

YAML 多文件，放 `configs/`（`server.yaml` / `data.yaml` / `client.yaml` / `logger.yaml` / `oss.yaml` / `registry.yaml` / `trace.yaml`）。结构体由 kratos-bootstrap 用 proto 生成。通过 `ctx.GetConfig()` 读取：

```yaml
# configs/data.yaml
data:
  database:
    driver: "postgres"
    source: "host=postgres port=5432 user=postgres password=*** dbname=gwl sslmode=disable"
    migrate: true
  redis:
    addr: "redis:6379"
```

```go
cfg := ctx.GetConfig()
if cfg.Data.Database.GetMigrate() { ... }
```

## 数据库迁移

- **schema 即代码**：ent schema 定义表结构，运行时 `client.Schema.Create(...)` 自动建表/加索引（`data.yaml` 中 `migrate: true` 时）
- **种子/演示数据**：`sql/` 目录的 `postgresql-demo-data.sql` / `mysql-demo-data.sql`
- **部分默认数据 Go 初始化**：如默认超级用户在 `UserService.init()` 中从 `pkg/constants` 写入

## 请求校验（双轨制）

1. **proto 声明式**：`google.api.field_behavior = REQUIRED` 标记必填；`validate/validate.proto`（PGV）做规则校验；gRPC 中间件 `enable_validate` 自动拦截
2. **业务层手写**：service 方法开头做 `nil` 检查与参数合法性，返回 Kratos 错误：

```go
if req == nil || req.Data == nil {
    return nil, adminV1.ErrorBadRequest("invalid request")
}
```

## 中间件

在 `rest_server.go` / `grpc_server.go` 以 `[]middleware.Middleware` 组装。REST 中间件链：

```go
func NewRestMiddleware(...) []middleware.Middleware {
    var ms []middleware.Middleware
    ms = append(ms, logging.Server(ctx.GetLogger()))          // 请求日志
    rpc.AddWhiteList(adminV1.OperationAuthenticationServiceLogin)  // Login 免鉴权白名单
    ms = append(ms, applogging.Server(...))                   // API/登录 审计日志
    ms = append(ms, selector.Server(                          // 认证 + 鉴权（带白名单匹配）
        auth.Server(auth.WithAccessTokenChecker(...)),
        authz.Server(authorizer),
    ).Match(rpc.NewRestWhiteListMatcher()).Build())
    return ms
}
```

- **认证（authn）**：`pkg/middleware/auth` — JWT 解析 → 校验 → 注入 user/tenant/orgUnit 到 context、ent viewer、metadata
- **鉴权（authz）**：Casbin / OPA / noop 引擎可切换
- **审计日志**：`pkg/middleware/logging` — API 调用日志、登录日志落库到 core
- **gRPC 侧**：recovery/tracing/validate/circuit_breaker/metadata 由配置开关启用

## 国际化（i18n）

后端 i18n 是**数据驱动**（翻译表实体 + 机器翻译服务），**不是文案 i18n**：
- 内容多语言通过独立翻译表实体（`category_translation`、`page_translation` 等）+ `language` 实体管理
- 机器翻译通过 `translator` 服务（Google Translate）
- 错误消息文案为硬编码（中/英混合），**无** response message 语言切换机制

## 构建与开发命令

项目用**两级 Makefile**：根 `Makefile`（编排，遍历各服务）+ 每服务 `app.mk`。

| 命令 | 作用 |
|------|------|
| `make gen` | ★ 一键全流程：`ent + wire + api + openapi`（新增接口/实体后首选） |
| `make api` | proto → Go 代码（`cd api && buf generate`） |
| `make ent` | 生成 ent ORM 代码 |
| `make wire` | 生成 wire 依赖注入代码 |
| `make openapi` | 生成 OpenAPI v3 文档 |
| `make build` | `api + openapi` 再编译各服务 |
| `make build_only` | 跳过生成，仅编译 |
| `make test` / `make cover` | 测试 / 覆盖率 |
| `make vet` / `make lint` | `go vet` / `golangci-lint run` |
| `make run` | 在服务目录运行（`go run ./cmd/server -c ./configs`） |
| `make compose-up-libs` | 仅启动依赖中间件（postgres/redis/minio/etcd/jaeger，不含应用） |
| `make compose-up` | 全栈 docker compose 编排 |
| `make all` | `make app`（生成+构建全流程） |

**开发工作流**：改 proto/ent/构造函数后 → `make gen`（重新生成全部） → `make build` → `make run`。

## Swagger / API 文档

OpenAPI v3 由 proto 自动生成（`make openapi`），Swagger UI 内嵌运行时：
- Admin Swagger UI: `http://localhost:6600/docs/`
- App Swagger UI: `http://localhost:6700/docs/`
- 配置开关：`configs/server.yaml` 中 `enable_swagger: true`

## 新增业务模块 Checklist（以 user 模块为模板）

```
- [ ] Step 1: 定义 proto 接口（api/protos/<domain>/service/v1/{entity}.proto + {entity}_error.proto）
- [ ] Step 2: 重新生成 → make api（生成 Go stub、HTTP/gRPC、错误助手、validate）
- [ ] Step 3: （仅 core）定义 ent schema（app/core/service/internal/data/ent/schema/{entity}.go）
- [ ] Step 4: （仅 core）make ent 生成 ent 代码
- [ ] Step 5: （仅 core）实现 repo（internal/data/{entity}_repo.go：接口 + 实现 + 事务模式）
- [ ] Step 6: （仅 core）在 data/providers/wire_set.go 注册 NewXxxRepo
- [ ] Step 7: 实现 core service（internal/service/{entity}_service.go，嵌入 UnimplementedXxxServer）
- [ ] Step 8: 在 service/providers/wire_set.go 注册 NewXxxService
- [ ] Step 9: （如对外 REST）在 core/server/grpc_server.go 注册 gRPC service
- [ ] Step 10: （admin/app 网关）实现薄 BFF service（注入 XxxServiceClient，转发）
- [ ] Step 11: 在 admin/server/rest_server.go 调用 RegisterXxxHTTPServer
- [ ] Step 12: make wire 重新生成依赖注入
- [ ] Step 13: make build → make run 验证
```

## 快速参考索引

### 常用命令速查

| 操作 | 命令 |
|------|------|
| 新增 proto 后 | `make api` |
| 新增 ent schema 后 | `make ent` |
| 新增构造函数后 | `make wire` |
| 全量生成 | `make gen` |
| 编译 | `make build` |
| 运行 | `make run` |
| 仅启中间件 | `make compose-up-libs` |
| 全栈 Docker | `make compose-up` |

### 领域 proto 速查

| 领域 | proto 文件数 | 用途 |
|------|:---:|------|
| `admin` | 43 | Admin BFF 后台管理接口 |
| `app` | 19 | App BFF 用户端接口 |
| `ledger` | 14 | 核心记账领域（账户/账本/流水/分类/标签/预算等） |
| `identity` | 13 | 身份认证/租户/用户/组织 |
| `permission` | 13 | RBAC 权限/角色/菜单/策略 |
| `audit` | 9 | 5 类审计日志 |
| `authentication` | 9 | 登录/令牌/MFA/登录策略 |
| `dict` | 4 | 字典/语言 |
| `internal_message` | 4 | 站内消息 |
| `storage` | 4 | 文件存储/OSS |
| `task` | 2 | 异步任务 |

### 错误码速查

| 错误助手 | HTTP 状态码 | 使用场景 |
|----------|:---:|----------|
| `ErrorBadRequest` | 400 | 参数无效 |
| `ErrorUnauthorized` | 401 | 未认证 |
| `ErrorNotFound` | 404 | 资源不存在 |
| `ErrorInternalServerError` | 500 | 内部错误 |
| `ErrorForbidden` | 403 | 无权限 |

## 常见错误与纠正

| 错误做法 | 正确做法 |
|---|---|
| 在 admin/app service 里操作 ent / DB | 数据访问只能在 core-service 的 `internal/data/` |
| 手改 `api/gen/`、`*/ent/`（非 schema）、`wire_gen.go` | 这些是生成产物，改源（proto / ent schema / wire.go）后 `make gen` |
| 改 proto 后不重新生成 | 执行 `make api`（或 `make gen`） |
| `return nil, errors.New("xxx")` | 用生成的 Kratos 错误助手 `identityV1.ErrorBadRequest("xxx")` |
| `fmt.Println` / 标准 `log` 做业务日志 | 用注入的 `*log.Helper`（`s.log.Errorf`） |
| 手写 HTTP 路由 | 由 proto 的 `google.api.http` 注解生成，在 server 层 `RegisterXxxHTTPServer` |
| 新增构造函数不注册 ProviderSet | 必须加到对应层 `providers/wire_set.go` 再 `make wire` |
| 接口与实现同名（都叫 `UserRepo`） | 接口 `UserRepo`，实现 `userRepo`，`NewUserRepo` 返回接口类型 |
| repo 里直接 Commit/Rollback 散落 | 用统一的 `defer { rollback/commit }` 闭包模式 |
| 手写 SQL 迁移脚本 | ent schema 即迁移源，`migrate: true` 自动建表 |

## FAQ

<details>
<summary><b>Proto 生成后编译报错："undefined: xxxV1.Xxx"？</b></summary>

1. 确认 proto 文件中的 `package` 和 `go_package` 是否正确
2. 检查 `make api` 是否成功执行
3. 确认 import 路径与 go.mod 的 module 路径一致
4. 如果新增了 import 其他 proto，确认被 import 的 proto 也已生成
</details>

<details>
<summary><b>Ent schema 怎么加新字段？</b></summary>

1. 编辑 `app/core/service/internal/data/ent/schema/{entity}.go` 的 `Fields()` 方法
2. 执行 `make ent` 重新生成 ent 代码
3. 如果字段需要暴露给 API，同步更新 proto message 定义
4. 更新 repo 层的 DTO 转换逻辑（`mapper.CopierMapper`）
</details>

<details>
<summary><b>Wire 注入链路怎么看？</b></summary>

1. 看 `cmd/server/wire_gen.go`（生成产物），它包含完整的注入拓扑
2. 追 `ProviderSet` 的组合：`cmd/server/wire.go` → `data/providers/wire_set.go` → `service/providers/wire_set.go` → `server/providers/wire_set.go`
3. `wire_gen.go` 报错通常是某层 ProviderSet 缺少构造函数注册
</details>

<details>
<summary><b>怎么区分 admin/app service 和 core service 的职责？</b></summary>

- **admin/app service**: 只做参数校验 + gRPC 转发到 core，**不访问数据库**
- **core service**: 实现真正的业务逻辑 + 数据持久化
- 如果发现自己在 admin/app 的 service 里 import 了 ent 或 repo，那就是放错地方了
</details>

<details>
<summary><b>事务应该写在哪一层？</b></summary>

事务只能在 **core service 的 repo 层**。使用标准化的 `defer { rollback/commit }` 闭包模式（见上文 repo 模板）。不要在其他层开启事务。
</details>

<details>
<summary><b>新增 BFF 接口的完整流程？</b></summary>

1. 在 `api/protos/admin/service/v1/` 或 `app/service/v1/` 创建 `i_xxx.proto`
2. 复用 core domain 的 message（import 方式）
3. 添加 `google.api.http` 注解定义 REST 路由
4. `make api` 生成代码
5. 在 admin/app 的 service 层实现薄转发
6. 在 `rest_server.go` 注册 HTTP 路由
7. `make wire` → `make build` → `make run`
</details>

## 关键文件索引

**架构骨架**
- `app/<svc>/service/cmd/server/main.go` — 启动入口
- `app/<svc>/service/cmd/server/wire.go` — DI 声明（wireinject）
- `app/<svc>/service/cmd/server/wire_gen.go` — DI 生成结果（查注入拓扑）
- `app/<svc>/service/internal/server/rest_server.go` — HTTP server + 路由 + 中间件
- `app/<svc>/service/internal/server/grpc_server.go` — gRPC server + 中间件

**user 模块（完整链路参考）**
- `api/protos/identity/service/v1/user.proto` — API/模型契约
- `api/protos/identity/service/v1/user_error.proto` — 错误码契约
- `app/admin/service/internal/service/user_service.go` — admin 网关（转发）
- `app/core/service/internal/service/user_service.go` — core 业务
- `app/core/service/internal/data/user_repo.go` — 仓储（事务模式范本）
- `app/core/service/internal/data/ent/schema/user.go` — ent 实体定义

**基础设施**
- `app/core/service/internal/data/ent_client.go` — ent 连接 + 自动迁移
- `app/<svc>/service/configs/` — 运行时配置（server.yaml / data.yaml / client.yaml）
- `pkg/middleware/auth/` — 认证鉴权中间件
- `pkg/middleware/logging/` — 审计日志中间件
- `pkg/entgo/mixin/` — 通用 ent mixin（AutoIncrementId / OperatorID / TimeAt / TenantID）
- `pkg/serviceid/` — 服务发现命名常量
