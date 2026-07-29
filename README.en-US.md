<div align="center">

# GoWind Ledger

### FengXing Ledger · Out-of-the-Box Personal/Family Full-Stack Bookkeeping Platform

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.25+-00ADD8?logo=go&logoColor=white)](https://go.dev/)
[![Vue](https://img.shields.io/badge/Vue-3.x-4FC08D?logo=vue.js&logoColor=white)](https://vuejs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Kratos](https://img.shields.io/badge/Kratos-2.9-00ADD8?logo=go&logoColor=white)](https://go-kratos.dev/)
[![Ent](https://img.shields.io/badge/Ent-0.14-00ADD8?logo=go&logoColor=white)](https://entgo.io/)

**English** · **[中文](./README.md)** · **[日本語](./README.ja-JP.md)**

</div>

---

## Table of Contents

- [Overview](#overview)
- [Quick Start by Role](#quick-start-by-role)
- [System Architecture](#system-architecture)
- [Tech Stack](#tech-stack)
- [Core Features](#core-features)
- [Project Structure](#project-structure)
- [Prerequisites & Launch](#prerequisites--launch)
- [Development Commands](#development-commands)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

## Overview

FengXing Ledger (GoWind Ledger) is a full-stack personal/family bookkeeping platform built on Go microservices architecture. It provides complete income/expense management, multi-account management, hierarchical category/tag system, multi-currency exchange rates, statistical reports, and recurring reminders. It supports both an Admin management console and a Flutter cross-platform mobile application.

**Key Highlights:**

- **Bookkeeping Engine** — Four flow types: expense/income/transfer/balance adjustment, single-entry bookkeeping, category/tag amount splitting
- **Multi-Account** — Checking/credit/asset/debt account types, automatic balance updates, cross-currency transfers
- **Hierarchical Categories** — Expense/income categories with 4-level tree structure, tags with capability flags (can expense/income/transfer)
- **Multi-Currency** — Built-in currency exchange rate cache, real-time rate refresh and currency conversion
- **Reports & Analytics** — Aggregation by category/tag/payee dimensions, asset/liability overview, ECharts visualization
- **Budget Management** — Monthly/quarterly/yearly/weekly budgets with real-time progress tracking and overspend alerts
- **Group Member Management** — Invite/accept/reject workflow, multi-role permissions (owner/operator/guest), tenant member management
- **Recurring Reminders** — Daily/monthly/yearly recurring reminders with run/recall operations
- **Microservices** — Built on go-kratos with Admin BFF + App BFF + Core three-service architecture
- **API First** — Protobuf contract-driven, RESTful + gRPC dual protocol, auto-generated OpenAPI docs

## Quick Start by Role

| Role | Recommended Reading |
|:---|:---|
| 🖥️ **Backend Developer** | [Architecture](#system-architecture) → [Tech Stack·Backend](#backend) → [Prerequisites](#prerequisites--launch) → [Commands](#development-commands) → [backend/AGENTS.md](./backend/AGENTS.md) |
| 🎨 **Frontend Developer** | [Tech Stack·Admin](#admin-console) → [Prerequisites](#prerequisites--launch) → [frontend/admin/AGENTS.md](./frontend/admin/AGENTS.md) |
| 📱 **Mobile Developer** | [Tech Stack·Mobile](#mobile-app) → [Prerequisites](#prerequisites--launch) → [frontend/app/flutter_app/AGENTS.md](./frontend/app/flutter_app/AGENTS.md) |
| 🔧 **DevOps / Full-Stack** | [Architecture](#system-architecture) → [Prerequisites](#prerequisites--launch) → [backend/AGENTS.md](./backend/AGENTS.md) |

## System Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        Client Layer                               │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │  Admin Console   │  │   Flutter App    │  │  Swagger UI   │ │
│  │  Vue3 + AntDV    │  │   BLoC + Dio     │  │  /docs/       │ │
│  └────────┬─────────┘  └────────┬─────────┘  └───────┬───────┘ │
└───────────┼─────────────────────┼─────────────────────┼─────────┘
            │ REST :6600          │ REST :6700          │
            ▼                     ▼                     ▼
┌──────────────────────────────────────────────────────────────────┐
│                     BFF Gateway Layer                             │
│  ┌──────────────────────┐    ┌──────────────────────┐           │
│  │     Admin BFF        │    │      App BFF         │           │
│  │  /admin/v1/* (REST)  │    │  /app/v1/* (REST)    │           │
│  │  Validate + gRPC fwd │    │  Validate + gRPC fwd │           │
│  └──────────┬───────────┘    └──────────┬───────────┘           │
└─────────────┼──────────────────────────┼────────────────────────┘
              │ gRPC                     │ gRPC
              ▼                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Core Service (gRPC)                            │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐     │
│  │  Book  │ │Account │ │  Flow  │ │ Report │ │ Currency │     │
│  └────────┘ └────────┘ └────────┘ └────────┘ └──────────┘     │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐     │
│  │Category│ │  Tag   │ │ Payee  │ │NoteDay │ │ FlowFile │     │
│  └────────┘ └────────┘ └────────┘ └────────┘ └──────────┘     │
│         │                                                        │
│         │ Ent ORM → PostgreSQL                                   │
│         │ Redis · MinIO · ElasticSearch · etcd                  │
└─────────┴────────────────────────────────────────────────────────┘
```

**Architecture Notes:**
- **Admin BFF** (`:6600`) and **App BFF** (`:6700`) are thin gateways — they do **not** access the database directly
- All data operations are handled by the **Core Service** (gRPC)
- Swagger UI is embedded in each BFF service: Admin `/docs/`, App `/docs/`

## Tech Stack

### Backend

| Layer       | Technology                                                                 | Description                    |
|:------------|:---------------------------------------------------------------------------|:-------------------------------|
| Language    | [Go 1.25+](https://go.dev/)                                                | High-performance compiled lang |
| Framework   | [go-kratos](https://go-kratos.dev/)                                        | Bilibili microservice framework|
| DI          | [Wire](https://github.com/google/wire)                                     | Compile-time dependency injection |
| ORM         | [Ent](https://entgo.io/)                                                   | Go entity framework            |
| Database    | [PostgreSQL](https://www.postgresql.org/) / [MySQL](https://www.mysql.com/) | Relational database           |
| Cache       | [Redis](https://redis.io/)                                                 | In-memory database            |
| Storage     | [MinIO](https://min.io/)                                                   | S3-compatible object storage  |
| Discovery   | [Etcd](https://etcd.io/)                                                   | Service discovery & config    |
| Tracing     | [Jaeger](https://www.jaegertracing.io/) + [OpenTelemetry](https://opentelemetry.io/) | Distributed observability |
| API Def     | [Protobuf](https://protobuf.dev/) + [buf.build](https://buf.build/)        | Contract-first API            |
| Authz       | [Casbin](https://casbin.org/) / [OPA](https://www.openpolicyagent.org/)    | Policy-driven authorization   |

### Admin Console

| Technology                                    | Description              |
|:----------------------------------------------|:------------------------|
| [Vue 3](https://vuejs.org/)                   | Progressive JS framework |
| [TypeScript](https://www.typescriptlang.org/) | Type safety             |
| [Ant Design Vue](https://antdv.com/)          | Enterprise UI components|
| [Vben Admin](https://doc.vben.pro/)           | Admin framework         |
| [Vxe Table](https://vxetable.cn/)            | High-perf table component|
| [ECharts](https://echarts.apache.org/)        | Data visualization      |

### Mobile App

| Technology                                    | Description              |
|:----------------------------------------------|:------------------------|
| [Flutter](https://flutter.dev/)               | Cross-platform framework |
| [BLoC](https://bloclibrary.dev/)              | State management        |
| [go_router](https://pub.dev/packages/go_router) | Declarative routing   |
| [Dio](https://pub.dev/packages/dio)           | HTTP client            |
| [cached_query](https://pub.dev/packages/cached_query) | Data caching & query |

## Core Features

### Bookkeeping Engine

| Feature         | Description                                                          |
|:----------------|:---------------------------------------------------------------------|
| Transactions    | Expense/income/transfer/adjustment, category amount splitting, tags  |
| Balance Confirm | Auto-update account balance on confirm, auto-refund on delete       |
| Analytics       | Aggregate by category/tag/payee, expense/income/net stats            |
| Cross-Currency  | Auto-calculate converted amount for cross-currency transfers         |

### Accounts & Books

| Feature         | Description                                                          |
|:----------------|:---------------------------------------------------------------------|
| Book Management | Multi-tenant books, default account/category config, enable/disable  |
| Account Types   | Checking/credit/asset/debt, capability flags, balance adjustment    |
| Currency        | Built-in currency rates, refresh and conversion                      |

### Category System

| Feature         | Description                                                          |
|:----------------|:---------------------------------------------------------------------|
| Hierarchical    | 4-level expense/income category tree, book-scoped                   |
| Tags            | Tree structure with capability flags (can expense/income/transfer)   |
| Payees          | Book-scoped payee management with capability flags                   |
| Reminders       | Daily/monthly/yearly recurring reminders with run/recall             |

### Budget Management

| Feature         | Description                                                          |
|:----------------|:---------------------------------------------------------------------|
| Budget Setup    | Monthly/quarterly/yearly/weekly budgets, scoped by category or account |
| Progress Track  | Real-time spending aggregation, remaining amount and usage percentage |
| Overspend Alert | Auto-flag when budget exceeded, configurable notification toggle      |

### Group Member Management

| Feature         | Description                                                          |
|:----------------|:---------------------------------------------------------------------|
| Invite Workflow | Invite users by username, invitees can accept or reject              |
| Role Permissions| Owner/operator/guest roles, owners manage members and settings       |
| Member Management| List tenant members, remove members (owner protected), view roles   |
| Multi-Tenant    | Users can belong to multiple tenants, switch active tenant/book      |

### Security

| Feature         | Description                                                          |
|:----------------|:---------------------------------------------------------------------|
| Multi-Tenant    | All data isolated by tenant via ent TenantID mixin                  |
| JWT Auth        | HS256 JWT tokens, Admin/App dual authentication                     |
| RBAC            | Casbin/OPA policy engine, menu/API/data three-level permissions     |
| Audit Logs      | API/login/operation/data-access/permission audit logging             |

## Project Structure

```
go-wind-ledger/
├── backend/                     # Backend microservices
│   ├── api/                     # Proto contracts + generated code
│   │   ├── protos/              # Proto source files (11 domains, 134 files)
│   │   │   ├── ledger/          # Ledger domain models
│   │   │   ├── admin/           # Admin BFF interfaces
│   │   │   ├── app/             # App BFF interfaces
│   │   │   └── identity/        # Identity/tenant/org models
│   │   └── gen/go/              # Generated Go code (do not edit)
│   ├── app/                     # Microservice apps (3 independent services)
│   │   ├── admin/service/       # Admin BFF gateway (REST :6600)
│   │   ├── app/service/         # App BFF gateway (REST :6700)
│   │   └── core/service/        # Core service (gRPC, 50 ent schemas)
│   ├── pkg/                     # Shared libraries (16 packages)
│   ├── sql/                     # Database seed/demo data
│   └── scripts/                 # Deployment & environment scripts
├── frontend/                    # Frontend apps
│   ├── admin/                   # Admin console (Vue3 + Vben Admin)
│   │   └── apps/admin/src/
│   │       ├── api/composables/ # 38 Vue Query composables
│   │       ├── views/app/ledger/# 12 ledger module pages
│   │       └── router/          # Auto-loading routes (7 modules)
│   └── app/
│       └── flutter_app/         # Flutter mobile app
│           └── lib/src/features/ledger/
│               ├── services/    # 13 ledger services
│               ├── pages/       # 22 ledger pages
│               └── widgets/     # 4 shared widgets
└── docker-compose.yaml          # Infrastructure orchestration
```

## Prerequisites & Launch

### Prerequisites

- Go 1.25+
- Node.js 20+ / pnpm 9+
- Flutter 3.12+ / Dart 3.12+
- Docker & Docker Compose
- PostgreSQL 15+ / Redis 7+ / MinIO / etcd

### 1. Start Infrastructure

```bash
cd backend
docker-compose up -d postgres redis minio etcd
```

### 2. Start Backend Services

```bash
cd backend
make compose-up-libs    # Start infrastructure
make run                # Run all services
```

After startup:
- Admin API: `http://localhost:6600/`
- App API: `http://localhost:6700/`
- Admin Swagger: `http://localhost:6600/docs/`
- App Swagger: `http://localhost:6700/docs/`

### 3. Start Admin Console

```bash
cd frontend/admin
pnpm install
pnpm dev
```

### 4. Start Flutter App

```bash
cd frontend/app/flutter_app
flutter pub get
flutter run
```

## Development Commands

| Command          | Description                              |
|:-----------------|:-----------------------------------------|
| `make gen`       | Full codegen (ent + wire + api + openapi)|
| `make api`       | Proto → Go code generation               |
| `make ent`       | Ent ORM code generation                  |
| `make wire`      | Wire DI code generation                  |
| `make build`     | Build all services                      |
| `make run`       | Run all services                        |
| `make compose-up`| Docker Compose start all                |

## FAQ

<details>
<summary><b>Port conflict: 6600 / 6700 already in use?</b></summary>

Modify the `server.http.addr` field in the corresponding service's `configs/server.yaml`.
</details>

<details>
<summary><b>Proto generation fails?</b></summary>

1. Confirm `buf` is installed: `buf --version`
2. Verify proto syntax, especially import paths
3. Run `make api` to regenerate
4. If still failing, check `api/buf.gen.yaml` configuration
</details>

<details>
<summary><b>Ent generation causes compilation errors?</b></summary>

1. Ensure ent schemas are in `app/core/service/internal/data/ent/schema/`
2. Run `make ent` to regenerate
3. If using custom templates, check `entc.go` configuration
</details>

<details>
<summary><b>Can admin/app services access the database directly?</b></summary>

**No.** Admin and App services are thin gateways — they only validate parameters and forward gRPC calls. All database operations must occur in the Core service. See [backend/AGENTS.md](./backend/AGENTS.md).
</details>

<details>
<summary><b>How to add a new ledger domain entity?</b></summary>

Full workflow in [backend/AGENTS.md · New Module Checklist](./backend/AGENTS.md#新增业务模块-checklist以-user-模块为模板). Summary: proto → make api → ent schema → make ent → repo → service → wire → gateway forwarding.
</details>

<details>
<summary><b>Where are the frontend API types defined?</b></summary>

Types are auto-generated from protobuf in `frontend/admin/apps/admin/src/api/generated/`. **Do not edit manually.** Import through the `#/api` barrel entry.
</details>

## Contributing

This project follows a **Protobuf-first (contract-first)** development model. All interface changes must be defined in proto files first. Each sub-project has its own AI coding guidelines:

| Document | Description |
|:---|:---|
| [backend/AGENTS.md](./backend/AGENTS.md) | Backend coding guidelines (Go + Kratos + Ent) |
| [frontend/admin/AGENTS.md](./frontend/admin/AGENTS.md) | Admin frontend coding guidelines (Vue3 + Vben) |
| [frontend/app/flutter_app/AGENTS.md](./frontend/app/flutter_app/AGENTS.md) | Flutter mobile coding guidelines |
| [backend/SKILL.md](./backend/SKILL.md) | Backend module development skills |
| [frontend/admin/SKILL.md](./frontend/admin/SKILL.md) | Admin frontend development skills |
| [frontend/app/flutter_app/SKILL.md](./frontend/app/flutter_app/SKILL.md) | Flutter mobile development skills |

## License

[MIT License](./LICENSE)
