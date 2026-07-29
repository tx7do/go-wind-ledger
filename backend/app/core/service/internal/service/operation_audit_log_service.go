package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-ledger/app/core/service/internal/data"

	auditV1 "go-wind-ledger/api/gen/go/audit/service/v1"
)

type OperationAuditLogService struct {
	auditV1.UnimplementedOperationAuditLogServiceServer
	repo *data.OperationAuditLogRepo
	log  *log.Helper
}

func NewOperationAuditLogService(ctx *bootstrap.Context, repo *data.OperationAuditLogRepo) *OperationAuditLogService {
	return &OperationAuditLogService{
		log:  ctx.NewLoggerHelper("operation_audit_log/service/core-service"),
		repo: repo,
	}
}

func (s *OperationAuditLogService) List(ctx context.Context, req *paginationV1.PagingRequest) (*auditV1.ListOperationAuditLogResponse, error) {
	return s.repo.List(ctx, req)
}
