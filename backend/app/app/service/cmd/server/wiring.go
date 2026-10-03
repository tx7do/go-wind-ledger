package main

import (
	"github.com/go-kratos/kratos/v2"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"go-wind-ledger/app/app/service/internal/data"
	"go-wind-ledger/app/app/service/internal/server"
	"go-wind-ledger/app/app/service/internal/service"
	"go-wind-ledger/pkg/middleware/auth"
)

// initApp 手写装配整个应用,是本服务的依赖注入点(替代原 google/wire 生成)。
// initApp assembles the whole application by hand — the dependency injection point.
//
// 装配严格单向分层,自上而下的阅读顺序即依赖方向:
// The wiring is strictly layered; reading top-down follows the dependency direction:
//
//	基础设施 → 服务客户端(data) → 服务层(service) → 传输层(server)
//
// 本服务是 BFF 网关:不直连数据库,仓储层由对 core-service 的 gRPC 服务客户端替代。
// 约定 / Conventions:
//   - 新增模块:先加服务客户端行,再加服务构造行,并传给 NewRestServer;漏接由编译器在调用处报错。
//     To add a module: append a service-client line, then a service constructor, then pass it to
//     NewRestServer; a missing connection is a compile error at the call site.
//   - 持有 cleanup 的资源创建成功后立即注册进 cleanups;任何一步失败,rollback 逆序执行已注册
//     的清理(shutdown 与中途失败共用同一条 LIFO 路径)。
//     Resources owning a cleanup register it immediately; rollback runs them LIFO both on
//     mid-way failure and on shutdown.
//   - 本文件只做构造与传参,不写业务逻辑。
//     Construction and parameter passing only; no business logic in this file.
func initApp(ctx *bootstrap.Context) (*kratos.App, func(), error) {
	// cleanup 注册表:本服务无持有 cleanup 的资源,rollback 为空实现,保持各服务同构的返回签名。
	// No cleanup-owning resources in this service; rollback is a no-op kept for
	// signature parity across the wiring files.
	var cleanups []func()
	rollback := func() {
		for i := len(cleanups) - 1; i >= 0; i-- {
			cleanups[i]()
		}
	}

	// ═══════════════════════ 一、基础设施 ═══════════════════════

	discovery := data.NewDiscovery(ctx)
	authenticationServiceClient := data.NewAuthenticationServiceClient(ctx, discovery)
	clientType := data.NewClientType()
	accessTokenChecker := auth.NewTokenChecker(ctx, authenticationServiceClient, clientType)
	engine := data.NewAuthorizer()
	minIOClient := data.NewMinIoClient(ctx)

	// ═══════════════════════ 二、服务客户端(internal/data) ═══════════════════════

	fileServiceClient := data.NewFileServiceClient(ctx, discovery)
	userServiceClient := data.NewUserServiceClient(ctx, discovery)
	tenantServiceClient := data.NewTenantServiceClient(ctx, discovery)
	orgUnitServiceClient := data.NewOrgUnitServiceClient(ctx, discovery)
	positionServiceClient := data.NewPositionServiceClient(ctx, discovery)
	roleServiceClient := data.NewRoleServiceClient(ctx, discovery)
	userCredentialServiceClient := data.NewUserCredentialServiceClient(ctx, discovery)
	bookServiceClient := data.NewBookServiceClient(ctx, discovery)
	bookTemplateServiceClient := data.NewBookTemplateServiceClient(ctx, discovery)
	accountServiceClient := data.NewAccountServiceClient(ctx, discovery)
	balanceFlowServiceClient := data.NewBalanceFlowServiceClient(ctx, discovery)
	categoryServiceClient := data.NewLedgerCategoryServiceClient(ctx, discovery)
	tagServiceClient := data.NewLedgerTagServiceClient(ctx, discovery)
	payeeServiceClient := data.NewPayeeServiceClient(ctx, discovery)
	noteDayServiceClient := data.NewNoteDayServiceClient(ctx, discovery)
	currencyServiceClient := data.NewCurrencyServiceClient(ctx, discovery)
	reportServiceClient := data.NewReportServiceClient(ctx, discovery)
	flowFileServiceClient := data.NewFlowFileServiceClient(ctx, discovery)
	budgetServiceClient := data.NewBudgetServiceClient(ctx, discovery)
	tenantMemberServiceClient := data.NewTenantMemberServiceClient(ctx, discovery)
	ledgerAuthServiceClient := data.NewLedgerAuthServiceClient(ctx, discovery)

	// ── register:client ── 新模块服务客户端在此行后注册(make register 工具锚点,勿删)

	// ═══════════════════════ 三、服务层(internal/service) ═══════════════════════

	authenticationService := service.NewAuthenticationService(ctx, authenticationServiceClient)
	fileTransferService := service.NewFileTransferService(ctx, minIOClient, fileServiceClient)
	userProfileService := service.NewUserProfileService(ctx, userServiceClient, tenantServiceClient, orgUnitServiceClient, positionServiceClient, roleServiceClient, userCredentialServiceClient)
	bookService := service.NewBookService(ctx, bookServiceClient)
	bookTemplateService := service.NewBookTemplateService(ctx, bookTemplateServiceClient)
	accountService := service.NewAccountService(ctx, accountServiceClient)
	balanceFlowService := service.NewBalanceFlowService(ctx, balanceFlowServiceClient)
	ledgerCategoryService := service.NewLedgerCategoryService(ctx, categoryServiceClient)
	ledgerTagService := service.NewLedgerTagService(ctx, tagServiceClient)
	payeeService := service.NewPayeeService(ctx, payeeServiceClient)
	noteDayService := service.NewNoteDayService(ctx, noteDayServiceClient)
	currencyService := service.NewCurrencyService(ctx, currencyServiceClient)
	reportService := service.NewReportService(ctx, reportServiceClient)
	flowFileService := service.NewFlowFileService(ctx, flowFileServiceClient)
	budgetService := service.NewBudgetService(ctx, budgetServiceClient)
	tenantMemberService := service.NewTenantMemberService(ctx, tenantMemberServiceClient)
	ledgerAuthService := service.NewLedgerAuthService(ctx, ledgerAuthServiceClient)

	// ── register:service ── 新模块服务在此行后注册(make register 工具锚点,勿删)

	// ═══════════════════════ 四、传输层(internal/server) ═══════════════════════

	restMiddlewares := server.NewRestMiddleware(ctx, accessTokenChecker, engine)

	httpServer := server.NewRestServer(ctx, restMiddlewares,
		authenticationService,
		fileTransferService,
		userProfileService,
		bookService,
		bookTemplateService,
		accountService,
		balanceFlowService,
		ledgerCategoryService,
		ledgerTagService,
		payeeService,
		noteDayService,
		currencyService,
		reportService,
		flowFileService,
		budgetService,
		tenantMemberService,
		ledgerAuthService,
		// register:rest-arg ── 新模块服务实参在此行后追加(make register 工具锚点,勿删)
	)

	grpcMiddlewares := server.NewGrpcMiddleware(ctx)

	grpcServer, err := server.NewGrpcServer(ctx, grpcMiddlewares)
	if err != nil {
		rollback()
		return nil, nil, err
	}

	sseServer := server.NewSseServer(ctx)

	return newApp(ctx, httpServer, grpcServer, sseServer), rollback, nil
}
