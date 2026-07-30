package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/go-utils/trans"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	appV1 "go-wind-ledger/api/gen/go/app/service/v1"
	authenticationV1 "go-wind-ledger/api/gen/go/authentication/service/v1"

	"go-wind-ledger/pkg/middleware/auth"
)

type AuthenticationService struct {
	appV1.AuthenticationServiceHTTPServer

	authenticationServiceClient authenticationV1.AuthenticationServiceClient

	log *log.Helper
}

func NewAuthenticationService(
	ctx *bootstrap.Context,
	authenticationServiceClient authenticationV1.AuthenticationServiceClient,
) *AuthenticationService {
	return &AuthenticationService{
		log:                         ctx.NewLoggerHelper("authn/service/app-service"),
		authenticationServiceClient: authenticationServiceClient,
	}
}

// Login 登陆
func (s *AuthenticationService) Login(ctx context.Context, req *authenticationV1.LoginRequest) (*authenticationV1.LoginResponse, error) {
	if req == nil {
		return nil, authenticationV1.ErrorBadRequest("invalid request")
	}

	req.ClientType = trans.Ptr(authenticationV1.ClientType_app)

	// 刷新令牌现为自验证 JWT，身份（uid/jti）由 core 服务从令牌自身解析，
	// BFF 不再需要从 access-token 中间件注入的 operator 取值写回请求。
	// 这使得刷新端点可免认证（access token 已过期也能续期），实现无感刷新。

	return s.authenticationServiceClient.Login(ctx, req)
}

// Logout 登出
func (s *AuthenticationService) Logout(ctx context.Context, _ *emptypb.Empty) (*emptypb.Empty, error) {
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}

	return s.authenticationServiceClient.Logout(ctx, &authenticationV1.LogoutRequest{
		ClientType: authenticationV1.ClientType_app,
		UserId:     operator.GetUserId(),
	})
}
