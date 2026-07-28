package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-cms/app/core/service/internal/data"

	auditV1 "go-wind-cms/api/gen/go/audit/service/v1"
)

type LoginAuditLogService struct {
	auditV1.UnimplementedLoginAuditLogServiceServer
	repo *data.LoginAuditLogRepo
	log  *log.Helper
}

func NewLoginAuditLogService(ctx *bootstrap.Context, repo *data.LoginAuditLogRepo) *LoginAuditLogService {
	return &LoginAuditLogService{
		log:  ctx.NewLoggerHelper("login_audit_log/service/core-service"),
		repo: repo,
	}
}

func (s *LoginAuditLogService) List(ctx context.Context, req *paginationV1.PagingRequest) (*auditV1.ListLoginAuditLogResponse, error) {
	return s.repo.List(ctx, req)
}
