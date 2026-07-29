package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/go-utils/trans"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	appV1 "go-wind-ledger/api/gen/go/app/service/v1"
	identityV1 "go-wind-ledger/api/gen/go/identity/service/v1"

	"go-wind-ledger/pkg/middleware/auth"
)

type TenantMemberService struct {
	appV1.TenantMemberServiceHTTPServer

	client identityV1.TenantMemberServiceClient
	log    *log.Helper
}

func NewTenantMemberService(ctx *bootstrap.Context, client identityV1.TenantMemberServiceClient) *TenantMemberService {
	return &TenantMemberService{
		log:    ctx.NewLoggerHelper("membership/service/app-service"),
		client: client,
	}
}

func (s *TenantMemberService) ListMembers(ctx context.Context, req *identityV1.ListMembersRequest) (*identityV1.ListMembersResponse, error) {
	return s.client.ListMembers(ctx, req)
}

func (s *TenantMemberService) InviteMember(ctx context.Context, req *identityV1.InviteMemberRequest) (*identityV1.Membership, error) {
	// 邀请操作由下游服务基于操作人身份记录 assigned_by
	_, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}
	return s.client.InviteMember(ctx, req)
}

func (s *TenantMemberService) AcceptInvite(ctx context.Context, req *identityV1.AcceptInviteRequest) (*identityV1.Membership, error) {
	return s.client.AcceptInvite(ctx, req)
}

func (s *TenantMemberService) RejectInvite(ctx context.Context, req *identityV1.RejectInviteRequest) (*emptypb.Empty, error) {
	return s.client.RejectInvite(ctx, req)
}

func (s *TenantMemberService) RemoveMember(ctx context.Context, req *identityV1.RemoveMemberRequest) (*emptypb.Empty, error) {
	return s.client.RemoveMember(ctx, req)
}

func (s *TenantMemberService) ListMyTenants(ctx context.Context, req *identityV1.ListMyTenantsRequest) (*identityV1.ListMyTenantsResponse, error) {
	return s.client.ListMyTenants(ctx, req)
}

func (s *TenantMemberService) GetMembership(ctx context.Context, req *identityV1.GetMembershipRequest) (*identityV1.Membership, error) {
	return s.client.GetMembership(ctx, req)
}

func (s *TenantMemberService) UpdateMembership(ctx context.Context, req *identityV1.UpdateMembershipRequest) (*identityV1.Membership, error) {
	if req.Data == nil {
		return nil, appV1.ErrorBadRequest("invalid parameter")
	}
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}
	req.Data.UpdatedBy = trans.Ptr(operator.GetUserId())
	if req.UpdateMask != nil {
		req.UpdateMask.Paths = append(req.UpdateMask.Paths, "updated_by")
	}
	return s.client.UpdateMembership(ctx, req)
}
