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

// Get retrieves a OperationAuditLog by ID.
func (s *OperationAuditLogService) Get(ctx context.Context, req *auditV1.GetOperationAuditLogRequest) (*auditV1.OperationAuditLog, error) {
	return nil, auditV1.ErrorNotFound("OperationAuditLog not found")
}

// Create records a new OperationAuditLog entry.
func (s *OperationAuditLogService) Create(ctx context.Context, req *auditV1.CreateOperationAuditLogRequest) (*emptypb.Empty, error) {
	if req == nil || req.Data == nil {
		return nil, auditV1.ErrorBadRequest("invalid request")
	}
	// Use the repo's ent client to create the record
	// Audit logs are write-only system records, no need for viewer context
	err := s.repo.Create(ctx, req)
	if err != nil {
		s.log.Errorf("create OperationAuditLog failed: %s", err.Error())
		return nil, auditV1.ErrorInternalServerError("create OperationAuditLog failed")
	}
	return &emptypb.Empty{}, nil
}
