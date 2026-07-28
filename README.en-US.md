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

FengXing Ledger (GoWind Ledger) is a full-stack personal/family bookkeeping platform built on Go microservices architecture. It provides complete income/expense management, multi-account management, hierarchical category/tag system, multi-currency exchange rates, statistical reports, and recurring reminders. It supports both an Admin management console and a Flutter cross-platform mobile application.

**Key Highlights:**

- **Bookkeeping Engine** — Four flow types: expense/income/transfer/balance adjustment, single-entry bookkeeping, category/tag amount splitting
- **Multi-Account** — Checking/credit/asset/debt account types, automatic balance updates, cross-currency transfers
- **Hierarchical Categories** — Expense/income categories with 4-level tree structure, tags with capability flags (can expense/income/transfer)
- **Multi-Currency** — Built-in 10 currency exchange rate cache, real-time rate refresh and currency conversion
- **Reports & Analytics** — Aggregation by category/tag/payee dimensions, asset/liability overview, ECharts visualization
- **Recurring Reminders** — Daily/monthly/yearly recurring reminders with run/recall operations
- **Microservices** — Built on go-kratos with Admin BFF + App BFF + Core three-service architecture
- **API First** — Protobuf contract-driven, RESTful + gRPC dual protocol, auto-generated OpenAPI docs

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Client Layer                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  Admin Console│ │  Flutter App │  │   Swagger    │    │
│  │  Vue3+AntDV  │  │  BLoC+Dio    │  │   /docs/     │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
└─────────┼────────────────┼────────────────┼────────────┘
          │ REST :6600     │ REST :6700     │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────┐
│                  BFF Gateway Layer                       │
│  ┌─────────────┐         ┌─────────────┐               │
│  │ Admin BFF   │         │  App BFF    │               │
│  │ /admin/v1/* │         │  /app/v1/*  │               │
│  └──────┬──────┘         └──────┬──────┘               │
└─────────┼───────────────────────┼──────────────────────┘
          │ gRPC                  │ gRPC
          ▼                       ▼
┌─────────────────────────────────────────────────────────┐
│                  Core Service Layer                      │
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
| Currency        | 10 built-in currency rates, refresh and conversion                   |

### Category System

| Feature         | Description                                                          |
|:----------------|:---------------------------------------------------------------------|
| Hierarchical    | 4-level expense/income category tree, book-scoped                   |
| Tags            | Tree structure with capability flags (can expense/income/transfer)   |
| Payees          | Book-scoped payee management with capability flags                   |
| Reminders       | Daily/monthly/yearly recurring reminders with run/recall             |

### Security

| Feature         | Description                                                          |
|:----------------|:---------------------------------------------------------------------|
| Multi-Tenant    | All data isolated by tenant via ent TenantID mixin                  |
| JWT Auth        | HS256 JWT tokens, Admin/App dual authentication                     |
| RBAC            | Casbin/OPA policy engine, menu/API/data three-level permissions     |
| Audit Logs      | API/login/operation/data-access/permission audit logging             |

## Quick Start

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

## License

[MIT License](./LICENSE)
