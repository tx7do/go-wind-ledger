//go:build wireinject
// +build wireinject

//go:generate go run github.com/google/wire/cmd/wire

// This file defines the dependency injection ProviderSet for the data layer and contains no business logic.
// The build tag `wireinject` excludes this source from normal `go build` and final binaries.
// Run `go generate ./...` or `go run github.com/google/wire/cmd/wire` to regenerate the Wire output (e.g. `wire_gen.go`), which will be included in final builds.
// Keep provider constructors here only; avoid init-time side effects or runtime logic in this file.

package providers

import (
	"github.com/google/wire"

	"go-wind-ledger/app/admin/service/internal/service"
)

// ProviderSet is the Wire provider set for data layer.
var ProviderSet = wire.NewSet(
	service.NewAuthenticationService,
	service.NewLoginPolicyService,

	service.NewUserService,
	service.NewRoleService,
	service.NewTenantService,
	service.NewUserProfileService,
	service.NewPositionService,
	service.NewOrgUnitService,

	service.NewMenuService,
	service.NewApiService,
	service.NewPermissionGroupService,
	service.NewPermissionService,

	service.NewRouterService,

	service.NewTaskService,

	service.NewFileService,

	service.NewDictTypeService,
	service.NewDictEntryService,
	service.NewLanguageService,

	service.NewApiAuditLogService,
	service.NewDataAccessAuditLogService,
	service.NewLoginAuditLogService,
	service.NewOperationAuditLogService,
	service.NewPermissionAuditLogService,
	service.NewPolicyEvaluationLogService,

	// === 站内信 ===
	service.NewInternalMessageService,
	service.NewInternalMessageCategoryService,
	service.NewInternalMessageRecipientService,

	// === 记账系统 Admin BFF Services ===
	service.NewBookService,
	service.NewBookTemplateService,
	service.NewAccountService,
	service.NewPayeeService,
	service.NewLedgerCategoryService,
	service.NewLedgerTagService,
	service.NewBalanceFlowService,
	service.NewFlowFileService,
	service.NewNoteDayService,
	service.NewCurrencyService,
	service.NewReportService,
	service.NewBudgetService,

	// === 成员管理 Admin BFF Services ===
	service.NewTenantMemberService,
)
