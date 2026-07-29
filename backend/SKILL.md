# Skills: Backend Module Development

> 本文件定义后端开发中常用的可复用技能/工作流，供 AI 编码工具调用。

---

## skill: add-proto-service

**描述**: 按 Proto-first 工作流新增一个后端微服务模块（含 proto 定义、ent schema、repo、service、wire 注入）。

**前置条件**: 已确定领域（domain）名称和实体（entity）名称。

### 步骤

```
Step 1: 定义 proto 接口
  在 api/protos/<domain>/service/v1/{entity}.proto 定义 gRPC service + message
  在 api/protos/<domain>/service/v1/{entity}_error.proto 定义错误码 enum

Step 2: 重新生成
  cd backend && make api

Step 3: （仅 core）定义 ent schema
  在 app/core/service/internal/data/ent/schema/{entity}.go
  使用 mixin.AutoIncrementId + mixin.OperatorID + mixin.TimeAt + mixin.TenantID

Step 4: 重新生成 ent
  cd backend && make ent

Step 5: 实现 repo
  在 app/core/service/internal/data/{entity}_repo.go
  定义接口（大写）→ 实现（小写）→ 事务 defer 闭包模式
  构造函数 NewXxxRepo(...) UserRepo 返回接口类型

Step 6: 注册 repo 到 wire
  在 app/core/service/internal/data/providers/wire_set.go 添加 NewXxxRepo

Step 7: 实现 core service
  在 app/core/service/internal/service/{entity}_service.go
  嵌入 UnimplementedXxxServer → 注入 repo 接口 → 实现业务方法

Step 8: 注册 service 到 wire
  在 app/core/service/internal/service/providers/wire_set.go 添加 NewXxxService

Step 9: 注册 gRPC service
  在 app/core/service/internal/server/grpc_server.go 调用 RegisterXxxServer

Step 10: （BFF 网关）实现转发 service
  在 app/admin/service/internal/service/{entity}_service.go（admin 网关）
  注入 XxxServiceClient → 参数校验 → gRPC 转发到 core

Step 11: 注册 HTTP 路由
  在 app/admin/service/internal/server/rest_server.go 调用 RegisterXxxHTTPServer

Step 12: wire 生成
  cd backend && make wire

Step 13: 编译验证
  cd backend && make build && make run
```

### 关键检查点

- proto 的 `package` 格式为 `{domain}.service.v1`
- BFF proto 文件以 `i_` 开头（如 `i_account.proto`），复用 core domain message
- repo 接口返回类型是 `*domainV1.Xxx`（proto DTO），不是 `*ent.Xxx`
- 所有业务错误用生成的 `ErrorXxx` 助手函数，不用 `errors.New`

---

## skill: add-bff-route

**描述**: 在 Admin/App BFF 网关为新模块添加对外 REST 接口（core 层已实现 gRPC）。

**前置条件**: core service 已实现 gRPC 接口。

### 步骤

```
Step 1: 定义 BFF proto
  在 api/protos/admin/service/v1/i_{entity}.proto 或 app/service/v1/i_{entity}.proto
  import core domain 的 proto → 定义 REST service + google.api.http 注解

Step 2: 重新生成
  cd backend && make api

Step 3: 实现 BFF service
  在 app/admin/service/internal/service/{entity}_service.go
  注入 XxxServiceClient → 参数校验 → 直接转发到 core
  模板见 backend/AGENTS.md 的 "service 层（业务逻辑）" 章节

Step 4: 注册 HTTP 路由
  在 app/admin/service/internal/server/rest_server.go
  调用 adminV1.RegisterXxxHTTPServer(srv, xxxService)

Step 5: wire 生成
  cd backend && make wire

Step 6: 编译验证
  cd backend && make build && make run
```

### 注意事项

- BFF service **绝不能**直接操作数据库（不 import ent）
- 参数校验在 BFF 层做（`if req == nil || req.Data == nil`）
- 从 context 取操作者使用 `auth.FromContext(ctx)`

---

## skill: add-ent-field

**描述**: 为已有 ent schema 添加新字段。

### 步骤

```
Step 1: 编辑 schema
  在 app/core/service/internal/data/ent/schema/{entity}.go
  在 Fields() 方法中添加 field.String("new_field").Comment("注释").Optional() 等

Step 2: 重新生成
  cd backend && make ent

Step 3: 更新 proto message（如需暴露给 API）
  在 api/protos/<domain>/service/v1/{entity}.proto 添加对应字段

Step 4: 重新生成 proto
  cd backend && make api

Step 5: 更新 repo DTO 转换（如有自定义映射）
  在 app/core/service/internal/data/{entity}_repo.go
  更新 mapper.CopierMapper 或手动赋值逻辑
```

---

## skill: diagnose-compile-error

**描述**: 常见编译错误诊断流程。

### 常见错误类型

| 错误信息 | 诊断 | 解决 |
|----------|------|------|
| `undefined: xxxV1.Xxx` | proto 未生成或 import 路径错误 | `make api`；检查 go_package |
| `cannot use xxx as XxxRepo` | wire 注入类型不匹配 | 检查 ProviderSet 是否注册 + 构造函数返回类型 |
| `no schema for xxx` | ent schema 未生成 | `make ent`；确认 schema 在正确目录 |
| `import cycle not allowed` | 循环依赖 | 检查 proto import / Go import；抽取公共接口到 pkg |
| `NewXxxRepo redeclared` | 构造函数重复 | 检查 wire_set.go 是否重复注册 |
