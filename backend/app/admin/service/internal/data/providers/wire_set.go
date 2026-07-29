//go:build wireinject
// +build wireinject

//go:generate go run github.com/google/wire/cmd/wire

package providers

import (
	"github.com/google/wire"

	"go-wind-cms/app/admin/service/internal/data"

	"go-wind-cms/pkg/middleware/auth"
)

// ProviderSet is the Wire provider set for data layer.
var ProviderSet = wire.NewSet(
	data.NewRedisClient,
	data.NewMinIoClient,
	data.NewDiscovery,

	data.NewClientType,
	data.NewAuthorizer,

	data.NewTranslator,

	auth.NewTokenChecker,

	data.NewAuthenticationServiceClient,
	data.NewUserCredentialServiceClient,
	data.NewLoginPolicyServiceClient,

	data.NewUserServiceClient,
	data.NewRoleServiceClient,
	data.NewTenantServiceClient,
	data.NewOrgUnitServiceClient,
	data.NewPositionServiceClient,
	data.NewTenantMemberServiceClient,

	data.NewOssServiceClient,
	data.NewFileServiceClient,

	data.NewPermissionGroupServiceClient,
	data.NewPermissionServiceClient,
	data.NewApiServiceClient,
	data.NewMenuServiceClient,

	data.NewDictEntryServiceClient,
	data.NewDictTypeServiceClient,
	data.NewLanguageServiceClient,

	data.NewTaskServiceClient,

	data.NewPermissionAuditLogServiceClient,
	data.NewPolicyEvaluationLogServiceClient,
	data.NewApiAuditLogServiceClient,
	data.NewDataAccessAuditLogServiceClient,
	data.NewLoginAuditLogServiceClient,
	data.NewOperationAuditLogServiceClient,

	// === 记账系统 gRPC Clients ===
	data.NewBookServiceClient,
	data.NewBookTemplateServiceClient,
	data.NewAccountServiceClient,
	data.NewCategoryServiceClient,
	data.NewTagServiceClient,
	data.NewPayeeServiceClient,
	data.NewBalanceFlowServiceClient,
	data.NewFlowFileServiceClient,
	data.NewNoteDayServiceClient,
	data.NewCurrencyServiceClient,
	data.NewReportServiceClient,
	data.NewBudgetServiceClient,
)
