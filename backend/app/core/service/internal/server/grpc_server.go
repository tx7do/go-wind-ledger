package server

import (
	"github.com/go-kratos/kratos/v2/middleware"
	"github.com/go-kratos/kratos/v2/middleware/logging"
	"github.com/go-kratos/kratos/v2/transport/grpc"

	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"github.com/tx7do/kratos-bootstrap/rpc"

	"go-wind-ledger/app/core/service/internal/service"

	auditV1 "go-wind-ledger/api/gen/go/audit/service/v1"
	authenticationV1 "go-wind-ledger/api/gen/go/authentication/service/v1"
	dictV1 "go-wind-ledger/api/gen/go/dict/service/v1"
	identityV1 "go-wind-ledger/api/gen/go/identity/service/v1"
	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
	permissionV1 "go-wind-ledger/api/gen/go/permission/service/v1"
	storageV1 "go-wind-ledger/api/gen/go/storage/service/v1"
	taskV1 "go-wind-ledger/api/gen/go/task/service/v1"

	appV1 "go-wind-ledger/api/gen/go/app/service/v1"

	"go-wind-ledger/pkg/middleware/ent"
)

func NewGrpcMiddleware(ctx *bootstrap.Context) []middleware.Middleware {
	var ms []middleware.Middleware
	ms = append(ms, logging.Server(ctx.GetLogger()))
	ms = append(ms, ent.Server())
	return ms
}

// NewGrpcServer new a gRPC server.
func NewGrpcServer(
	ctx *bootstrap.Context,
	middlewares []middleware.Middleware,

	authenticationService *service.AuthenticationService,
	loginPolicyService *service.LoginPolicyService,
	userCredentialService *service.UserCredentialService,

	taskService *service.TaskService,

	fileService *service.FileService,

	languageService *service.LanguageService,

	tenantService *service.TenantService,
	userService *service.UserService,
	roleService *service.RoleService,
	positionService *service.PositionService,
	orgUnitService *service.OrgUnitService,

	menuService *service.MenuService,
	apiService *service.ApiService,
	permissionService *service.PermissionService,
	permissionGroupService *service.PermissionGroupService,
	permissionAuditLogService *service.PermissionAuditLogService,
	policyEvaluationLogService *service.PolicyEvaluationLogService,

	loginAuditLogService *service.LoginAuditLogService,
	apiAuditLogService *service.ApiAuditLogService,
	operationAuditLogService *service.OperationAuditLogService,
	dataAccessAuditLogService *service.DataAccessAuditLogService,

	// === 记账系统 Services ===
	bookService          *service.BookService,
	accountService       *service.AccountService,
	categoryService      *service.CategoryService,
	tagService           *service.TagService,
	payeeService         *service.PayeeService,
	balanceFlowService   *service.BalanceFlowService,
	noteDayService       *service.NoteDayService,
	currencyService      *service.CurrencyService,
	reportService        *service.ReportService,
	flowFileService      *service.FlowFileService,
		membershipService    *service.MembershipService,
		budgetService        *service.BudgetService,
		bookTemplateService  *service.BookTemplateService,

		// === 记账认证服务 ===
		ledgerAuthService *service.LedgerAuthService,
	) (*grpc.Server, error) {
	cfg := ctx.GetConfig()

	if cfg == nil || cfg.Server == nil || cfg.Server.Grpc == nil {
		return nil, nil
	}

	srv, err := rpc.CreateGrpcServer(cfg, middlewares...)
	if err != nil {
		return nil, err
	}

	taskV1.RegisterTaskServiceServer(srv, taskService)

	authenticationV1.RegisterLoginPolicyServiceServer(srv, loginPolicyService)
	authenticationV1.RegisterAuthenticationServiceServer(srv, authenticationService)
	authenticationV1.RegisterUserCredentialServiceServer(srv, userCredentialService)

	dictV1.RegisterLanguageServiceServer(srv, languageService)

	permissionV1.RegisterApiServiceServer(srv, apiService)
	permissionV1.RegisterMenuServiceServer(srv, menuService)

	permissionV1.RegisterPermissionServiceServer(srv, permissionService)
	permissionV1.RegisterPermissionGroupServiceServer(srv, permissionGroupService)
	permissionV1.RegisterPolicyEvaluationLogServiceServer(srv, policyEvaluationLogService)
	permissionV1.RegisterRoleServiceServer(srv, roleService)

	identityV1.RegisterUserServiceServer(srv, userService)
	identityV1.RegisterOrgUnitServiceServer(srv, orgUnitService)
	identityV1.RegisterPositionServiceServer(srv, positionService)
	identityV1.RegisterTenantServiceServer(srv, tenantService)
	identityV1.RegisterTenantMemberServiceServer(srv, membershipService)

	auditV1.RegisterLoginAuditLogServiceServer(srv, loginAuditLogService)
	auditV1.RegisterApiAuditLogServiceServer(srv, apiAuditLogService)
	auditV1.RegisterOperationAuditLogServiceServer(srv, operationAuditLogService)
	auditV1.RegisterDataAccessAuditLogServiceServer(srv, dataAccessAuditLogService)
	auditV1.RegisterPermissionAuditLogServiceServer(srv, permissionAuditLogService)

	storageV1.RegisterFileServiceServer(srv, fileService)

	// === 记账系统 gRPC 注册 ===
	ledgerV1.RegisterBookServiceServer(srv, bookService)
	ledgerV1.RegisterAccountServiceServer(srv, accountService)
	ledgerV1.RegisterCategoryServiceServer(srv, categoryService)
	ledgerV1.RegisterTagServiceServer(srv, tagService)
	ledgerV1.RegisterPayeeServiceServer(srv, payeeService)
	ledgerV1.RegisterBalanceFlowServiceServer(srv, balanceFlowService)
	ledgerV1.RegisterNoteDayServiceServer(srv, noteDayService)
	ledgerV1.RegisterCurrencyServiceServer(srv, currencyService)
	ledgerV1.RegisterReportServiceServer(srv, reportService)
	ledgerV1.RegisterFlowFileServiceServer(srv, flowFileService)
	ledgerV1.RegisterBudgetServiceServer(srv, budgetService)
	ledgerV1.RegisterBookTemplateServiceServer(srv, bookTemplateService)

	// === 记账认证服务 gRPC 注册 ===
	appV1.RegisterLedgerAuthServiceServer(srv, ledgerAuthService)

	return srv, nil
}
