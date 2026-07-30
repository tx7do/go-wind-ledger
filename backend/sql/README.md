# 测试数据 SQL

本目录存放开发/测试环境用的种子数据脚本。脚本会清空并重置相关表，**生产库请勿直接执行**。

## 文件清单

### 系统初始化数据（需先执行）

| 文件 | 说明 | 执行环境 |
| --- | --- | --- |
| `postgresql-demo-data.sql` | 系统层种子：租户、用户（`tenant_admin`）、组织架构、字典、站内信分类等 | PostgreSQL |
| `mysql-demo-data.sql` | 同上，MySQL 方言 | MySQL 8.0+ |

> `tenant_admin`（id=2）默认登录密码：`admin`。

### 账本业务测试数据（系统初始化之后执行）

| 文件 | 说明 | 执行环境 |
| --- | --- | --- |
| `postgresql-ledger-demo-data.sql` | 账本业务种子：账本、账户、流水、分类/标签（树）、收款人、预算、提醒、账本模板 | PostgreSQL |
| `mysql-ledger-demo-data.sql` | 同上，MySQL 方言 | MySQL 8.0+ |

这两个文件用于前端记账功能（账户列表、流水与统计卡片、分类/标签树、收款人、预算、提醒、账本模板）的联调与渲染测试，并提供如下数据状态以便覆盖各种 UI 分支：

- 四种账户类型（checking / credit / asset / debt）与不同 `enable` / `include` / `can_*` 开关组合；
- 支出 / 收入分类与标签的两级树结构；
- 预算覆盖 monthly / weekly / quarterly / yearly 四种周期，含 `used_amount > amount` 的超额态；
- 流水覆盖 expense / income / transfer / adjust 四种类型，`create_time` 分布在近 60 天，供统计卡片与分页加载测试。

### 依赖与执行顺序

1. 先执行系统初始化脚本（`*-demo-data.sql`）。
2. 再执行账本业务脚本（`*-ledger-demo-data.sql`）。

PostgreSQL 版的账本脚本会补齐 `sys_memberships` / `sys_membership_roles` 并设置 `user` / `tenant` 的 `default_book_id` 指向种子账本——否则 `InitState` 会向登录用户返回空账本，前端记账界面无数据。MySQL 版因 `mysql-demo-data.sql` 已含成员关系，仅补 `default_book_id`。

### 执行示例

```bash
# PostgreSQL（当前 docker-compose 启用的库）
psql -U postgres -d gwl -f postgresql-demo-data.sql
psql -U postgres -d gwl -f postgresql-ledger-demo-data.sql

# MySQL（需在 docker-compose 中取消注释 mysql 服务）
mysql -u admin -p gwl < mysql-demo-data.sql
mysql -u admin -p gwl < mysql-ledger-demo-data.sql
```

## 备注

- 所有金额、名称、备注均为示例占位文本，无真实含义。
- 币种数据不由 SQL 提供，由 `core-service` 的 `CurrencyService` 内存种子（`currency_service.go`）返回，前端币种页无需 SQL 即可工作。
