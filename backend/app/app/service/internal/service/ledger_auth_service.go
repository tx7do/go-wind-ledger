package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	appV1 "go-wind-ledger/api/gen/go/app/service/v1"
)

// LedgerAuthService 记账认证服务（App BFF）— 转发至 Core gRPC
type LedgerAuthService struct {
	appV1.LedgerAuthServiceHTTPServer

	client appV1.LedgerAuthServiceClient

	log *log.Helper
}

// NewLedgerAuthService 创建记账认证服务（App BFF）
func NewLedgerAuthService(
	ctx *bootstrap.Context,
	client appV1.LedgerAuthServiceClient,
) *LedgerAuthService {
	return &LedgerAuthService{
		log:    ctx.NewLoggerHelper("ledger-auth/service/app-service"),
		client: client,
	}
}

// Register 用户注册（自动创建默认租户和账本）
func (s *LedgerAuthService) Register(ctx context.Context, req *appV1.LedgerRegisterRequest) (*appV1.LedgerAuthResponse, error) {
	return s.client.Register(ctx, req)
}

// InitState 初始化状态（返回用户/租户/账本聚合信息）
func (s *LedgerAuthService) InitState(ctx context.Context, req *emptypb.Empty) (*appV1.InitStateResponse, error) {
	return s.client.InitState(ctx, req)
}

// SetDefaultBook 设置默认账本
func (s *LedgerAuthService) SetDefaultBook(ctx context.Context, req *appV1.SetDefaultBookRequest) (*emptypb.Empty, error) {
	return s.client.SetDefaultBook(ctx, req)
}

// SetDefaultTenant 设置默认租户
func (s *LedgerAuthService) SetDefaultTenant(ctx context.Context, req *appV1.SetDefaultTenantRequest) (*emptypb.Empty, error) {
	return s.client.SetDefaultTenant(ctx, req)
}
