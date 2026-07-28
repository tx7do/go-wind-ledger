package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-cms/app/core/service/internal/data"

	auditV1 "go-wind-cms/api/gen/go/audit/service/v1"
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
