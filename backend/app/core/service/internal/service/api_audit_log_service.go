package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-cms/app/core/service/internal/data"

	auditV1 "go-wind-cms/api/gen/go/audit/service/v1"
)

type ApiAuditLogService struct {
	auditV1.UnimplementedApiAuditLogServiceServer
	repo *data.ApiAuditLogRepo
	log  *log.Helper
}

func NewApiAuditLogService(ctx *bootstrap.Context, repo *data.ApiAuditLogRepo) *ApiAuditLogService {
	return &ApiAuditLogService{
		log:  ctx.NewLoggerHelper("api_audit_log/service/core-service"),
		repo: repo,
	}
}

func (s *ApiAuditLogService) List(ctx context.Context, req *paginationV1.PagingRequest) (*auditV1.ListApiAuditLogResponse, error) {
	return s.repo.List(ctx, req)
}
