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

// Get retrieves a DataAccessAuditLog by ID.
func (s *DataAccessAuditLogService) Get(ctx context.Context, req *auditV1.GetDataAccessAuditLogRequest) (*auditV1.DataAccessAuditLog, error) {
	return nil, auditV1.ErrorNotFound("DataAccessAuditLog not found")
}

// Create records a new DataAccessAuditLog entry.
func (s *DataAccessAuditLogService) Create(ctx context.Context, req *auditV1.CreateDataAccessAuditLogRequest) (*emptypb.Empty, error) {
	if req == nil || req.Data == nil {
		return nil, auditV1.ErrorBadRequest("invalid request")
	}
	// Use the repo's ent client to create the record
	// Audit logs are write-only system records, no need for viewer context
	err := s.repo.Create(ctx, req)
	if err != nil {
		s.log.Errorf("create DataAccessAuditLog failed: %s", err.Error())
		return nil, auditV1.ErrorInternalServerError("create DataAccessAuditLog failed")
	}
	return &emptypb.Empty{}, nil
}
