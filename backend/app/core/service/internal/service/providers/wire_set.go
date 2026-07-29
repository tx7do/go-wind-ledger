//go:build wireinject
// +build wireinject

//go:generate go run github.com/google/wire/cmd/wire

// This file defines the dependency injection ProviderSet for the data layer and contains no business logic.
// The build tag `wireinject` excludes this source from normal `go build` and final binaries.
// Run `go generate ./...` or `go run github.com/google/wire/cmd/wire` to regenerate the Wire output (e.g. `wire_gen.go`), which will be included in final builds.
// Keep provider constructors here only; avoid init-time side effects or runtime logic in this file.

package providers

import (
	"go-wind-cms/app/core/service/internal/service"

	"github.com/google/wire"
)

// ProviderSet is the Wire provider set for service layer.
var ProviderSet = wire.NewSet(
	service.NewAuthenticationService,
	service.NewUserService,
	service.NewMenuService,
	service.NewTaskService,
	service.NewRoleService,
	service.NewOrgUnitService,
	service.NewPositionService,
	service.NewLanguageService,
	service.NewLoginAuditLogService,
	service.NewApiAuditLogService,
	service.NewFileService,
	service.NewTenantService,
	service.NewLoginPolicyService,
	service.NewUserCredentialService,
	service.NewApiService,
	service.NewPermissionService,
	service.NewPermissionGroupService,
	service.NewPolicyEvaluationLogService,
	service.NewPermissionAuditLogService,
	service.NewDataAccessAuditLogService,
	service.NewOperationAuditLogService,
	service.NewFileTransferService,

	// === 记账系统 Core Services ===
	service.NewBookService,
	service.NewAccountService,
	service.NewCategoryService,
	service.NewTagService,
	service.NewPayeeService,
	service.NewBalanceFlowService,
	service.NewNoteDayService,
	service.NewCurrencyService,
	service.NewReportService,
	service.NewFlowFileService,
		service.NewMembershipService,
		service.NewBudgetService,
		service.NewBookTemplateService,

		// === 记账认证服务 ===
		service.NewLedgerAuthService,
	)
