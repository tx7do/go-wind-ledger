<div align="center">

# GoWind Ledger

### 風行家計簿 · すぐに使える個人・家庭向けフルスタック家計管理プラットフォーム

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.25+-00ADD8?logo=go&logoColor=white)](https://go.dev/)
[![Vue](https://img.shields.io/badge/Vue-3.x-4FC08D?logo=vue.js&logoColor=white)](https://vuejs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Kratos](https://img.shields.io/badge/Kratos-2.9-00ADD8?logo=go&logoColor=white)](https://go-kratos.dev/)
[![Ent](https://img.shields.io/badge/Ent-0.14-00ADD8?logo=go&logoColor=white)](https://entgo.io/)

**[English](./README.en-US.md)** · **[中文](./README.md)** · **日本語**

</div>

---

## 目次

- [概要](#概要)
- [ロール別クイックスタート](#ロール別クイックスタート)
- [システムアーキテクチャ](#システムアーキテクチャ)
- [技術スタック](#技術スタック)
- [コア機能](#コア機能)
- [プロジェクト構造](#プロジェクト構造)
- [前提条件と起動](#前提条件と起動)
- [開発コマンド](#開発コマンド)
- [よくある質問 (FAQ)](#よくある質問-faq)
- [コントリビューション](#コントリビューション)
- [ライセンス](#ライセンス)

## 概要

風行家計簿（GoWind Ledger）は、Go マイクロサービスアーキテクチャに基づくフルスタックの個人・家庭向け家計管理プラットフォームです。収支管理、マルチアカウント管理、階層カテゴリ/タグシステム、多通貨為替レート、統計レポート、定期リマインダー機能を提供し、Admin 管理コンソールと Flutter クロスプラットフォームモバイルアプリの両方をサポートします。

**主な特徴：**

- **家計簿エンジン** — 支出/収入/振替/残高調整の 4 種類の取引タイプ、単式簿記エンジン、カテゴリ/タグ金額分割
- **マルチアカウント** — 当座/クレジット/資産/負債の 4 種類のアカウント、残高自動更新、クロス通貨振替対応
- **階層カテゴリ** — 支出/収入カテゴリは 4 階層のツリー構造をサポート、タグは機能フラグ（支出/収入/振替可）をサポート
- **多通貨** — 複数通貨の為替レートキャッシュ内蔵、リアルタイムレート更新と通貨換算計算をサポート
- **統計レポート** — カテゴリ/タグ/受取人別の集計分析、資産負債概览、ECharts 可視化
- **予算管理** — 月次/四半期/年次/週次の予算設定、リアルタイム進捗追跡、超過アラート通知
- **グループメンバー管理** — 招待/承認/拒否ワークフロー、多ロール権限（所有者/操作者/ゲスト）、テナントメンバー管理
- **定期リマインダー** — 毎日/毎月/毎年の繰り返しリマインダー、実行と取り消し操作をサポート
- **マイクロサービス** — go-kratos ベース、Admin BFF + App BFF + Core の 3 サービスアーキテクチャ
- **API ファースト** — Protobuf コントラクト駆動、RESTful + gRPC デュアルプロトコル、OpenAPI ドキュメント自動生成

## ロール別クイックスタート

| ロール | 推奨ガイド |
|:---|:---|
| 🖥️ **バックエンド開発者** | [アーキテクチャ](#システムアーキテクチャ) → [技術スタック·バックエンド](#バックエンド) → [前提条件](#前提条件と起動) → [コマンド](#開発コマンド) → [backend/AGENTS.md](./backend/AGENTS.md) |
| 🎨 **フロントエンド開発者** | [技術スタック·Admin](#admin-管理コンソール) → [前提条件](#前提条件と起動) → [frontend/admin/AGENTS.md](./frontend/admin/AGENTS.md) |
| 📱 **モバイル開発者** | [技術スタック·モバイル](#モバイルアプリ) → [前提条件](#前提条件と起動) → [frontend/app/flutter_app/AGENTS.md](./frontend/app/flutter_app/AGENTS.md) |
| 🔧 **DevOps / フルスタック** | [アーキテクチャ](#システムアーキテクチャ) → [前提条件](#前提条件と起動) → [backend/AGENTS.md](./backend/AGENTS.md) |

## システムアーキテクチャ

```
┌──────────────────────────────────────────────────────────────────┐
│                       クライアント層                               │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │  Admin コンソール │  │   Flutter App    │  │  Swagger UI   │ │
│  │  Vue3 + AntDV    │  │   BLoC + Dio     │  │  /docs/       │ │
│  └────────┬─────────┘  └────────┬─────────┘  └───────┬───────┘ │
└───────────┼─────────────────────┼─────────────────────┼─────────┘
            │ REST :6600          │ REST :6700          │
            ▼                     ▼                     ▼
┌──────────────────────────────────────────────────────────────────┐
│                     BFF ゲートウェイ層                              │
│  ┌──────────────────────┐    ┌──────────────────────┐           │
│  │     Admin BFF        │    │      App BFF         │           │
│  │  /admin/v1/* (REST)  │    │  /app/v1/* (REST)    │           │
│  │  パラメータ検証 + 転送 │    │  パラメータ検証 + 転送 │           │
│  └──────────┬───────────┘    └──────────┬───────────┘           │
└─────────────┼──────────────────────────┼────────────────────────┘
              │ gRPC                     │ gRPC
              ▼                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Core コアサービス (gRPC)                        │
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

**アーキテクチャのポイント：**
- **Admin BFF** (`:6600`) と **App BFF** (`:6700`) はシンゲートウェイで、**データベースに直接アクセスしません**
- すべてのデータ操作は **Core サービス**（gRPC）が処理します
- Swagger UI は各 BFF サービスに内蔵：Admin `/docs/`、App `/docs/`

## 技術スタック

### バックエンド

| レイヤー  | 技術                                                                 | 説明                     |
|:-------|:-------------------------------------------------------------------|:------------------------|
| 言語     | [Go 1.25+](https://go.dev/)                                        | 高性能コンパイル言語             |
| フレームワーク | [go-kratos](https://go-kratos.dev/)                                | Bilibili オープンソースマイクロサービス |
| DI     | [Wire](https://github.com/google/wire)                             | コンパイル時依存性注入            |
| ORM    | [Ent](https://entgo.io/)                                           | Go エンティティフレームワーク       |
| データベース | [PostgreSQL](https://www.postgresql.org/) / [MySQL](https://www.mysql.com/) | リレーショナルデータベース |
| キャッシュ  | [Redis](https://redis.io/)                                         | インメモリデータベース           |
| オブジェクトストレージ | [MinIO](https://min.io/)                                       | S3 互換オブジェクトストレージ      |
| サービス探索 | [Etcd](https://etcd.io/)                                           | サービスディスカバリと設定        |
| 分散トレーシング | [Jaeger](https://www.jaegertracing.io/) + [OpenTelemetry](https://opentelemetry.io/) | 分散可観測性 |
| API 定義 | [Protobuf](https://protobuf.dev/) + [buf.build](https://buf.build/) | コントラクトファースト API      |
| 認可エンジン | [Casbin](https://casbin.org/) / [OPA](https://www.openpolicyagent.org/) | ポリシー駆動認可      |

### Admin 管理コンソール

| 技術                                            | 説明               |
|:----------------------------------------------|:-----------------|
| [Vue 3](https://vuejs.org/)                   | プログレッシブ JS フレームワーク |
| [TypeScript](https://www.typescriptlang.org/) | 型安全性             |
| [Ant Design Vue](https://antdv.com/)          | エンタープライズ UI コンポーネント |
| [Vben Admin](https://doc.vben.pro/)           | 管理画面フレームワーク      |
| [Vxe Table](https://vxetable.cn/)            | 高性能テーブルコンポーネント   |
| [ECharts](https://echarts.apache.org/)        | データ可視化           |

### モバイルアプリ

| 技術                                            | 説明               |
|:----------------------------------------------|:-----------------|
| [Flutter](https://flutter.dev/)               | クロスプラットフォームフレームワーク |
| [BLoC](https://bloclibrary.dev/)              | 状態管理            |
| [go_router](https://pub.dev/packages/go_router) | 宣言型ルーティング      |
| [Dio](https://pub.dev/packages/dio)           | HTTP クライアント      |
| [cached_query](https://pub.dev/packages/cached_query) | データキャッシュとクエリ |

## コア機能

### 家計簿エンジン

| 機能        | 説明                                                         |
|:----------|:-----------------------------------------------------------|
| 取引管理      | 支出/収入/振替/残高調整の 4 種類、カテゴリ金額分割、タグ関連付け、添付ファイル管理            |
| 残高確認      | 取引確認後にアカウント残高を自動更新、削除時に自動ロールバック、資金の一貫性を保証             |
| 統計分析      | カテゴリ/タグ/受取人別の集計分析、支出/収入/純額統計、資産負債概览                 |
| クロス通貨振替   | 振替時に換算金額を自動計算、多通貨アカウント間の資金移動をサポート                   |

### アカウントと帳簿

| 機能        | 説明                                                         |
|:----------|:-----------------------------------------------------------|
| 帳簿管理      | マルチテナント帳簿、デフォルトアカウント/カテゴリ設定、有効/無効切り替え               |
| アカウント管理   | 当座/クレジット/資産/負債の 4 種類、機能フラグ（支出/収入/振替出/振替入可）、残高調整    |
| 残高調整      | 残高調整時に ADJUST 取引レコードを自動作成、調整監査証跡を保持                 |
| 通貨管理      | 複数通貨の為替レートキャッシュ内蔵、レート更新と通貨換算計算をサポート             |

### カテゴリシステム

| 機能        | 説明                                                         |
|:----------|:-----------------------------------------------------------|
| 階層カテゴリ    | 支出/収入カテゴリは 4 階層のツリー構造をサポート、帳簿別に分離                   |
| 階層タグ      | タグはツリー構造をサポート、機能フラグ（支出/収入/振替可）                    |
| 受取人管理     | 帳簿別に分離された受取人/支払人管理、機能フラグ制御                        |
| 定期リマインダー  | 毎日/毎月/毎年の繰り返しリマインダー、実行と取り消し操作をサポート                |

### 予算管理

| 機能        | 説明                                                         |
|:----------|:-----------------------------------------------------------|
| 予算設定      | 月次/四半期/年次/週次の予算設定、カテゴリまたはアカウント別に予算範囲を細分化可能         |
| 進捗追跡      | リアルタイムで取引を集計して使用済み金額を計算、残額と使用率を表示                 |
| 超過アラート    | 予算超過時に自動的にフラグを設定、通知オン/オフ切り替え可能                    |

### グループメンバー管理

| 機能        | 説明                                                         |
|:----------|:-----------------------------------------------------------|
| 招待ワークフロー  | ユーザー名でユーザーを招待、被招待者は承認または拒否可能                      |
| ロール権限     | 所有者/操作者/ゲストの 3 種類のロール、所有者はメンバーとテナント設定を管理        |
| メンバー管理     | テナントメンバーの一覧表示、メンバーの削除（所有者は保護）、ロールとステータスの表示    |
| マルチテナント帰属  | ユーザーは複数のテナントに所属可能、操作中のテナントと帳簿を切り替え               |

### セキュリティ

| 機能        | 説明                                                         |
|:----------|:-----------------------------------------------------------|
| マルチテナント分離 | すべての家計データはテナント別に分離、ent TenantID mixin に基づく          |
| JWT 認証    | HS256 JWT トークン、Admin/App デュアル認証設定                    |
| RBAC 認可   | Casbin/OPA ポリシーエンジン、メニュー/API/データの 3 レベル権限管理       |
| 監査ログ      | API/ログイン/操作/データアクセス/権限監査ログ                        |

## プロジェクト構造

```
go-wind-ledger/
├── backend/                     # バックエンドマイクロサービス
│   ├── api/                     # Proto コントラクト + 生成コード
│   │   ├── protos/              # Proto ソースファイル（11 ドメイン、134 ファイル）
│   │   │   ├── ledger/          # 家計簿ドメインモデル
│   │   │   ├── admin/           # Admin BFF インターフェース
│   │   │   ├── app/             # App BFF インターフェース
│   │   │   └── identity/        # アイデンティティ/テナント/組織モデル
│   │   └── gen/go/              # 生成された Go コード（編集禁止）
│   ├── app/                     # マイクロサービスアプリ（3 つの独立サービス）
│   │   ├── admin/service/       # Admin BFF ゲートウェイ（REST :6600）
│   │   ├── app/service/         # App BFF ゲートウェイ（REST :6700）
│   │   └── core/service/        # Core サービス（gRPC, 50 ent スキーマ）
│   ├── pkg/                     # 共有ライブラリ（16 パッケージ）
│   ├── sql/                     # データベースシード/デモデータ
│   └── scripts/                 # デプロイ・環境スクリプト
├── frontend/                    # フロントエンドアプリ
│   ├── admin/                   # Admin 管理コンソール（Vue3 + Vben Admin）
│   │   └── apps/admin/src/
│   │       ├── api/composables/ # 38 個の Vue Query composables
│   │       ├── views/app/ledger/# 12 の家計簿モジュールページ
│   │       └── router/          # 自動読み込みルート（7 モジュール）
│   └── app/
│       └── flutter_app/         # Flutter モバイルアプリ
│           └── lib/src/features/ledger/
│               ├── services/    # 13 の家計簿サービス
│               ├── pages/       # 22 の家計簿ページ
│               └── widgets/     # 4 つの共有ウィジェット
└── docker-compose.yaml          # インフラストラクチャ編成
```

## 前提条件と起動

### 前提条件

- Go 1.25+
- Node.js 20+ / pnpm 9+
- Flutter 3.12+ / Dart 3.12+
- Docker & Docker Compose
- PostgreSQL 15+ / Redis 7+ / MinIO / etcd

### 1. インフラストラクチャの起動

```bash
cd backend
docker-compose up -d postgres redis minio etcd
```

### 2. バックエンドサービスの起動

```bash
cd backend
make compose-up-libs    # インフラ起動
make run                # 全サービス実行
```

起動後：
- Admin API: `http://localhost:6600/`
- App API: `http://localhost:6700/`
- Admin Swagger: `http://localhost:6600/docs/`
- App Swagger: `http://localhost:6700/docs/`

### 3. Admin コンソールの起動

```bash
cd frontend/admin
pnpm install
pnpm dev
```

### 4. Flutter アプリの起動

```bash
cd frontend/app/flutter_app
flutter pub get
flutter run
```

## 開発コマンド

| コマンド              | 説明                                 |
|:------------------|:-----------------------------------|
| `make gen`        | 全コード生成（ent + wire + api + openapi）   |
| `make api`        | Proto → Go コード生成                  |
| `make ent`        | Ent ORM コード生成                    |
| `make wire`       | Wire DI コード生成                    |
| `make build`      | 全サービスコンパイル                       |
| `make run`        | 全サービス実行                         |
| `make compose-up` | Docker Compose 全起動                |

## よくある質問 (FAQ)

<details>
<summary><b>ポート競合：6600 / 6700 が既に使用されていますか？</b></summary>

対応するサービスの `configs/server.yaml` 内の `server.http.addr` フィールドを変更してください。
</details>

<details>
<summary><b>Proto 生成が失敗しますか？</b></summary>

1. `buf` がインストールされていることを確認：`buf --version`
2. proto ファイルの構文、特に import パスを確認
3. `make api` を実行して再生成
4. それでも失敗する場合は `api/buf.gen.yaml` の設定を確認
</details>

<details>
<summary><b>Ent 生成後にコンパイルエラーが発生しますか？</b></summary>

1. ent スキーマが `app/core/service/internal/data/ent/schema/` にあることを確認
2. `make ent` を実行して再生成
3. カスタムテンプレートを使用している場合は `entc.go` の設定を確認
</details>

<details>
<summary><b>admin/app サービスはデータベースに直接アクセスできますか？</b></summary>

**できません**。admin と app サービスはシンゲートウェイであり、パラメータ検証と gRPC 転送のみを行います。すべてのデータベース操作は Core サービスで行う必要があります。[backend/AGENTS.md](./backend/AGENTS.md) を参照してください。
</details>

<details>
<summary><b>新しい家計簿エンティティを追加するには？</b></summary>

完全なワークフローは [backend/AGENTS.md · 新規モジュールチェックリスト](./backend/AGENTS.md#新增业务模块-checklist以-user-模块为模板) を参照。概要：proto → make api → ent schema → make ent → repo → service → wire → ゲートウェイ転送。
</details>

<details>
<summary><b>フロントエンドの API 型はどこで定義されていますか？</b></summary>

型は protobuf から `frontend/admin/apps/admin/src/api/generated/` に自動生成されます。**手動で編集しないでください。** `#/api` バレルエントリを通じてインポートします。
</details>

## コントリビューション

本プロジェクトは **Protobuf-first（コントラクトファースト）** 開発モデルを採用しています。すべてのインターフェース変更は最初に proto ファイルで定義する必要があります。各サブプロジェクトには専用の AI コーディングガイドラインがあります：

| ドキュメント | 説明 |
|:---|:---|
| [backend/AGENTS.md](./backend/AGENTS.md) | バックエンドコーディングガイドライン（Go + Kratos + Ent） |
| [frontend/admin/AGENTS.md](./frontend/admin/AGENTS.md) | Admin フロントエンドコーディングガイドライン（Vue3 + Vben） |
| [frontend/app/flutter_app/AGENTS.md](./frontend/app/flutter_app/AGENTS.md) | Flutter モバイルコーディングガイドライン |
| [backend/SKILL.md](./backend/SKILL.md) | バックエンドモジュール開発スキル |
| [frontend/admin/SKILL.md](./frontend/admin/SKILL.md) | Admin フロントエンド開発スキル |
| [frontend/app/flutter_app/SKILL.md](./frontend/app/flutter_app/SKILL.md) | Flutter モバイル開発スキル |

## ライセンス

[MIT License](./LICENSE)
