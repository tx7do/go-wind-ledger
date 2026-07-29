package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-ledger/app/core/service/internal/data"

	auditV1 "go-wind-ledger/api/gen/go/audit/service/v1"
	"google.golang.org/protobuf/types/known/emptypb"
)

type PermissionAuditLogService struct {
	auditV1.UnimplementedPermissionAuditLogServiceServer
	repo *data.PermissionAuditLogRepo
	log  *log.Helper
}

func NewPermissionAuditLogService(ctx *bootstrap.Context, repo *data.PermissionAuditLogRepo) *PermissionAuditLogService {
	return &PermissionAuditLogService{
		log:  ctx.NewLoggerHelper("permission_audit_log/service/core-service"),
		repo: repo,
	}
}

func (s *PermissionAuditLogService) List(ctx context.Context, req *paginationV1.PagingRequest) (*auditV1.ListPermissionAuditLogResponse, error) {
	return s.repo.List(ctx, req)
}

// Get retrieves a PermissionAuditLog by ID.
func (s *PermissionAuditLogService) Get(ctx context.Context, req *auditV1.GetPermissionAuditLogRequest) (*auditV1.PermissionAuditLog, error) {
	return nil, auditV1.ErrorNotFound("PermissionAuditLog not found")
}

// Create records a new PermissionAuditLog entry.
func (s *PermissionAuditLogService) Create(ctx context.Context, req *auditV1.CreatePermissionAuditLogRequest) (*emptypb.Empty, error) {
	if req == nil || req.Data == nil {
		return nil, auditV1.ErrorBadRequest("invalid request")
	}
	// Use the repo's ent client to create the record
	// Audit logs are write-only system records, no need for viewer context
	err := s.repo.Create(ctx, req)
	if err != nil {
		s.log.Errorf("create PermissionAuditLog failed: %s", err.Error())
		return nil, auditV1.ErrorInternalServerError("create PermissionAuditLog failed")
	}
	return &emptypb.Empty{}, nil
}
