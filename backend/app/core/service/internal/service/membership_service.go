package service

import (
	"context"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/go-utils/trans"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"

	"go-wind-ledger/app/core/service/internal/data"

	identityV1 "go-wind-ledger/api/gen/go/identity/service/v1"
	permissionV1 "go-wind-ledger/api/gen/go/permission/service/v1"
)

// MembershipService 成员管理服务（邀请/接受/拒绝/列出/移除）。
// 注意：proto 中服务名为 TenantMemberService，生成的 Go 类型为
// TenantMemberServiceServer / RegisterTenantMemberServiceServer。
type MembershipService struct {
	identityV1.UnimplementedTenantMemberServiceServer

	log *log.Helper

	membershipRepo *data.MembershipRepo
	userRepo       data.UserRepo
	tenantRepo     *data.TenantRepo
	roleRepo       *data.RoleRepo
}

// NewMembershipService 创建成员管理服务。
func NewMembershipService(
	ctx *bootstrap.Context,
	membershipRepo *data.MembershipRepo,
	userRepo data.UserRepo,
	tenantRepo *data.TenantRepo,
	roleRepo *data.RoleRepo,
) *MembershipService {
	return &MembershipService{
		log:            ctx.NewLoggerHelper("membership/service/core-service"),
		membershipRepo: membershipRepo,
		userRepo:       userRepo,
		tenantRepo:     tenantRepo,
		roleRepo:       roleRepo,
	}
}

// ListMembers 列出租户成员（关联查询 user 表获取 username/nickname）。
func (s *MembershipService) ListMembers(ctx context.Context, req *identityV1.ListMembersRequest) (*identityV1.ListMembersResponse, error) {
	if req == nil || req.GetTenantId() == 0 {
		return nil, identityV1.ErrorBadRequest("invalid tenant id")
	}

	memberships, err := s.membershipRepo.ListByTenant(ctx, req.GetTenantId(), req.Status)
	if err != nil {
		return nil, err
	}

	// 收集 user_id 与 role_id 用于批量查询
	userIDs := make([]uint32, 0, len(memberships))
	roleIDs := make([]uint32, 0, len(memberships))
	for _, m := range memberships {
		if m.GetUserId() != 0 {
			userIDs = append(userIDs, m.GetUserId())
		}
		if m.GetRoleId() != 0 {
			roleIDs = append(roleIDs, m.GetRoleId())
		}
	}

	userMap := make(map[uint32]*identityV1.User, len(userIDs))
	if len(userIDs) > 0 {
		users, err := s.userRepo.ListUsersByIds(ctx, userIDs)
		if err != nil {
			s.log.Errorf("list users by ids failed: %s", err.Error())
		} else {
			for _, u := range users {
				userMap[u.GetId()] = u
			}
		}
	}

	roleMap := make(map[uint32]*permissionV1.Role, len(roleIDs))
	if len(roleIDs) > 0 {
		roles, err := s.roleRepo.ListRolesByRoleIds(ctx, roleIDs)
		if err != nil {
			s.log.Errorf("list roles by ids failed: %s", err.Error())
		} else {
			for _, r := range roles {
				roleMap[r.GetId()] = r
			}
		}
	}

	items := make([]*identityV1.MemberInfo, 0, len(memberships))
	for _, m := range memberships {
		info := &identityV1.MemberInfo{
			Id:        m.Id,
			UserId:    m.UserId,
			TenantId:  m.TenantId,
			RoleId:    m.RoleId,
			Status:    m.Status,
			IsPrimary: m.IsPrimary,
			JoinedAt:  m.JoinedAt,
		}
		if u, ok := userMap[m.GetUserId()]; ok {
			info.Username = u.Username
			info.Nickname = u.Nickname
		}
		if r, ok := roleMap[m.GetRoleId()]; ok {
			info.RoleName = r.Name
		}
		items = append(items, info)
	}

	return &identityV1.ListMembersResponse{Items: items, Total: uint64(len(items))}, nil
}

// InviteMember 按 username 查找 user，创建 status=INVITED 的 membership。
func (s *MembershipService) InviteMember(ctx context.Context, req *identityV1.InviteMemberRequest) (*identityV1.Membership, error) {
	if req == nil || req.GetTenantId() == 0 || req.GetUsername() == "" {
		return nil, identityV1.ErrorBadRequest("invalid request")
	}

	// 按 username 查找用户
	user, err := s.userRepo.Get(ctx, &identityV1.GetUserRequest{
		QueryBy: &identityV1.GetUserRequest_Username{Username: req.GetUsername()},
	})
	if err != nil {
		s.log.Errorf("find user by username failed: %s", err.Error())
		return nil, identityV1.ErrorNotFound("user not found")
	}

	// 检查是否已存在成员关系
	existing, _ := s.membershipRepo.FindByTenantAndUser(ctx, req.GetTenantId(), user.GetId())
	if existing != nil {
		return nil, identityV1.ErrorBadRequest("membership already exists")
	}

	// 创建 INVITED 成员关系
	data := &identityV1.Membership{
		TenantId:  trans.Ptr(req.GetTenantId()),
		UserId:    trans.Ptr(user.GetId()),
		Status:    identityV1.Membership_INVITED.Enum(),
		RoleId:    req.RoleId,
		IsPrimary: trans.Ptr(false),
	}
	return s.membershipRepo.Create(ctx, data)
}

// AcceptInvite 接受邀请：验证 status=INVITED，更新为 ACTIVE 并设置 joined_at。
func (s *MembershipService) AcceptInvite(ctx context.Context, req *identityV1.AcceptInviteRequest) (*identityV1.Membership, error) {
	if req == nil || req.GetId() == 0 {
		return nil, identityV1.ErrorBadRequest("invalid request")
	}

	m, err := s.membershipRepo.FindByID(ctx, req.GetId())
	if err != nil {
		return nil, err
	}
	if m.GetStatus() != identityV1.Membership_INVITED {
		return nil, identityV1.ErrorBadRequest("membership is not in invited status")
	}

	now := time.Now()
	updated, err := s.membershipRepo.Update(ctx, req.GetId(), &identityV1.Membership{
		Status:   identityV1.Membership_ACTIVE.Enum(),
		JoinedAt: timestamppb.New(now),
	}, nil)
	if err != nil {
		return nil, err
	}
	return updated, nil
}

// RejectInvite 拒绝邀请：验证 status=INVITED，标记为 REJECTED（保留记录）。
func (s *MembershipService) RejectInvite(ctx context.Context, req *identityV1.RejectInviteRequest) (*emptypb.Empty, error) {
	if req == nil || req.GetId() == 0 {
		return nil, identityV1.ErrorBadRequest("invalid request")
	}

	m, err := s.membershipRepo.FindByID(ctx, req.GetId())
	if err != nil {
		return nil, err
	}
	if m.GetStatus() != identityV1.Membership_INVITED {
		return nil, identityV1.ErrorBadRequest("membership is not in invited status")
	}

	if _, err := s.membershipRepo.UpdateStatus(ctx, req.GetId(), identityV1.Membership_REJECTED); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

// RemoveMember 移除成员：按 tenant+user 查找 membership，验证不是所有者，删除。
func (s *MembershipService) RemoveMember(ctx context.Context, req *identityV1.RemoveMemberRequest) (*emptypb.Empty, error) {
	if req == nil || req.GetTenantId() == 0 || req.GetUserId() == 0 {
		return nil, identityV1.ErrorBadRequest("invalid request")
	}

	m, err := s.membershipRepo.FindByTenantAndUser(ctx, req.GetTenantId(), req.GetUserId())
	if err != nil {
		return nil, err
	}
	_ = m

	// 验证不是租户所有者（管理员）
	tenant, err := s.tenantRepo.Get(ctx, &identityV1.GetTenantRequest{
		QueryBy: &identityV1.GetTenantRequest_Id{Id: req.GetTenantId()},
	})
	if err == nil && tenant != nil {
		if tenant.GetAdminUserId() == req.GetUserId() {
			return nil, identityV1.ErrorBadRequest("cannot remove tenant owner")
		}
	}

	if err := s.membershipRepo.DeleteByTenantAndUser(ctx, req.GetTenantId(), req.GetUserId()); err != nil {
		return nil, identityV1.ErrorInternalServerError("remove member failed")
	}

	return &emptypb.Empty{}, nil
}

// ListMyTenants 列出当前用户所属的租户（含成员角色）。
func (s *MembershipService) ListMyTenants(ctx context.Context, req *identityV1.ListMyTenantsRequest) (*identityV1.ListMyTenantsResponse, error) {
	if req == nil || req.GetUserId() == 0 {
		return nil, identityV1.ErrorBadRequest("invalid user id")
	}

	memberships, err := s.membershipRepo.FindByUser(ctx, req.GetUserId())
	if err != nil {
		return nil, err
	}

	// 收集 tenant_id 与 role_id 用于批量查询
	tenantIDs := make([]uint32, 0, len(memberships))
	roleIDs := make([]uint32, 0, len(memberships))
	for _, m := range memberships {
		if m.GetTenantId() != 0 {
			tenantIDs = append(tenantIDs, m.GetTenantId())
		}
		if m.GetRoleId() != 0 {
			roleIDs = append(roleIDs, m.GetRoleId())
		}
	}

	tenantMap := make(map[uint32]*identityV1.Tenant, len(tenantIDs))
	if len(tenantIDs) > 0 {
		tenants, err := s.tenantRepo.ListTenantsByIds(ctx, tenantIDs)
		if err != nil {
			s.log.Errorf("list tenants by ids failed: %s", err.Error())
		} else {
			for _, t := range tenants {
				tenantMap[t.GetId()] = t
			}
		}
	}

	roleMap := make(map[uint32]*permissionV1.Role, len(roleIDs))
	if len(roleIDs) > 0 {
		roles, err := s.roleRepo.ListRolesByRoleIds(ctx, roleIDs)
		if err != nil {
			s.log.Errorf("list roles by ids failed: %s", err.Error())
		} else {
			for _, r := range roles {
				roleMap[r.GetId()] = r
			}
		}
	}

	items := make([]*identityV1.TenantMembershipInfo, 0, len(memberships))
	for _, m := range memberships {
		info := &identityV1.TenantMembershipInfo{
			TenantId:     m.TenantId,
			MembershipId: m.Id,
			RoleId:       m.RoleId,
			Status:       m.Status,
			IsPrimary:    m.IsPrimary,
		}
		if t, ok := tenantMap[m.GetTenantId()]; ok {
			info.TenantName = t.Name
		}
		if r, ok := roleMap[m.GetRoleId()]; ok {
			info.RoleName = r.Name
		}
		items = append(items, info)
	}

	return &identityV1.ListMyTenantsResponse{Items: items, Total: uint64(len(items))}, nil
}

// GetMembership 获取成员详情。
func (s *MembershipService) GetMembership(ctx context.Context, req *identityV1.GetMembershipRequest) (*identityV1.Membership, error) {
	if req == nil || req.GetId() == 0 {
		return nil, identityV1.ErrorBadRequest("invalid id")
	}
	return s.membershipRepo.FindByID(ctx, req.GetId())
}

// UpdateMembership 更新成员（修改角色等）。
func (s *MembershipService) UpdateMembership(ctx context.Context, req *identityV1.UpdateMembershipRequest) (*identityV1.Membership, error) {
	if req == nil || req.GetData() == nil {
		return nil, identityV1.ErrorBadRequest("invalid request")
	}
	return s.membershipRepo.Update(ctx, req.GetId(), req.GetData(), req.GetUpdateMask())
}
