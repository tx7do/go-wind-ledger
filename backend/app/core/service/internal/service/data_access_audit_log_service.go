package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-cms/app/core/service/internal/data"

	auditV1 "go-wind-cms/api/gen/go/audit/service/v1"
)

type DataAccessAuditLogService struct {
	auditV1.UnimplementedDataAccessAuditLogServiceServer
	repo *data.DataAccessAuditLogRepo
	log  *log.Helper
}

func NewDataAccessAuditLogService(ctx *bootstrap.Context, repo *data.DataAccessAuditLogRepo) *DataAccessAuditLogService {
	return &DataAccessAuditLogService{
		log:  ctx.NewLoggerHelper("data_access_audit_log/service/core-service"),
		repo: repo,
	}
}

func (s *DataAccessAuditLogService) List(ctx context.Context, req *paginationV1.PagingRequest) (*auditV1.ListDataAccessAuditLogResponse, error) {
	return s.repo.List(ctx, req)
}
