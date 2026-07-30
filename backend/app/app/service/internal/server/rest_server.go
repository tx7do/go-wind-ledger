package server

import (
	"context"

	"github.com/go-kratos/kratos/v2/middleware"
	"github.com/go-kratos/kratos/v2/middleware/logging"
	"github.com/go-kratos/kratos/v2/middleware/selector"
	"github.com/go-kratos/kratos/v2/transport/http"

	authzEngine "github.com/tx7do/kratos-authz/engine"
	authz "github.com/tx7do/kratos-authz/middleware"

	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"github.com/tx7do/kratos-bootstrap/rpc"

	swaggerUI "github.com/tx7do/kratos-swagger-ui"

	"go-wind-ledger/app/app/service/cmd/server/assets"
	"go-wind-ledger/app/app/service/internal/service"

	appV1 "go-wind-ledger/api/gen/go/app/service/v1"
	auditV1 "go-wind-ledger/api/gen/go/audit/service/v1"

	"go-wind-ledger/pkg/middleware/auth"
	applogging "go-wind-ledger/pkg/middleware/logging"
)

// NewRestMiddleware 创建中间件
func NewRestMiddleware(
	ctx *bootstrap.Context,
	accessTokenChecker auth.AccessTokenChecker,
	authorizer authzEngine.Engine,
) []middleware.Middleware {
	var ms []middleware.Middleware
	ms = append(ms, logging.Server(ctx.GetLogger()))

	// add white list for authentication.
	rpc.AddWhiteList(
		appV1.OperationAuthenticationServiceLogin,

		// 刷新令牌端点免认证：刷新令牌现为自验证 JWT，身份由 core 从令牌自身
		// 解析，不再依赖 access-token 中间件。免认证使 access token 过期后仍可
		// 续期，实现无感刷新。
		appV1.OperationAuthenticationServiceRefreshToken,

		// 记账注册端点免认证
		appV1.OperationLedgerAuthServiceRegister,
	)

	ms = append(ms, applogging.Server(
		applogging.WithWriteApiLogFunc(func(ctx context.Context, data *auditV1.ApiAuditLog) error {
			return nil
		}),
		applogging.WithWriteLoginLogFunc(func(ctx context.Context, data *auditV1.LoginAuditLog) error {
			return nil
		}),
	))

	ms = append(ms, selector.Server(
		auth.Server(
			auth.WithAccessTokenChecker(accessTokenChecker),
			auth.WithInjectMetadata(true),
			auth.WithInjectEnt(true),
		),
		authz.Server(authorizer),
	).Match(rpc.NewRestWhiteListMatcher()).Build())

	return ms
}

// NewRestServer new an REST server.
func NewRestServer(
	ctx *bootstrap.Context,

	middlewares []middleware.Middleware,

	authenticationService *service.AuthenticationService,
	fileTransferService *service.FileTransferService,
	userProfileService *service.UserProfileService,

	bookService *service.BookService,
	bookTemplateService *service.BookTemplateService,
	accountService *service.AccountService,
	balanceFlowService *service.BalanceFlowService,
	ledgerCategoryService *service.LedgerCategoryService,
	ledgerTagService *service.LedgerTagService,
	payeeService *service.PayeeService,
	noteDayService *service.NoteDayService,
	currencyService *service.CurrencyService,
	reportService *service.ReportService,
	flowFileService *service.FlowFileService,
	budgetService *service.BudgetService,
	tenantMemberService *service.TenantMemberService,

	// === 记账认证服务 ===
	ledgerAuthService *service.LedgerAuthService,
) *http.Server {
	cfg := ctx.GetConfig()

	if cfg == nil || cfg.Server == nil || cfg.Server.Rest == nil {
		return nil
	}

	srv, err := rpc.CreateRestServer(cfg, middlewares...)
	if err != nil {
		panic(err)
	}

	appV1.RegisterAuthenticationServiceHTTPServer(srv, authenticationService)
	appV1.RegisterFileTransferServiceHTTPServer(srv, fileTransferService)
	appV1.RegisterUserProfileServiceHTTPServer(srv, userProfileService)

	appV1.RegisterBookServiceHTTPServer(srv, bookService)
	appV1.RegisterBookTemplateServiceHTTPServer(srv, bookTemplateService)
	appV1.RegisterAccountServiceHTTPServer(srv, accountService)
	appV1.RegisterBalanceFlowServiceHTTPServer(srv, balanceFlowService)
	appV1.RegisterLedgerCategoryServiceHTTPServer(srv, ledgerCategoryService)
	appV1.RegisterLedgerTagServiceHTTPServer(srv, ledgerTagService)
	appV1.RegisterPayeeServiceHTTPServer(srv, payeeService)
	appV1.RegisterNoteDayServiceHTTPServer(srv, noteDayService)
	appV1.RegisterCurrencyServiceHTTPServer(srv, currencyService)
	appV1.RegisterReportServiceHTTPServer(srv, reportService)
	appV1.RegisterFlowFileServiceHTTPServer(srv, flowFileService)
	appV1.RegisterBudgetServiceHTTPServer(srv, budgetService)
	appV1.RegisterTenantMemberServiceHTTPServer(srv, tenantMemberService)

	// === 记账认证服务 HTTP 注册 ===
	appV1.RegisterLedgerAuthServiceHTTPServer(srv, ledgerAuthService)

	if cfg.GetServer().GetRest().GetEnableSwagger() {
		swaggerUI.RegisterSwaggerUIServerWithOption(
			srv,
			swaggerUI.WithTitle("GoWind Content Hub App API"),
			swaggerUI.WithMemoryData(assets.OpenApiData, "yaml"),
		)
	}

	return srv
}
