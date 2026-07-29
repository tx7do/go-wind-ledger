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

// Get retrieves a ApiAuditLog by ID.
func (s *ApiAuditLogService) Get(ctx context.Context, req *auditV1.GetApiAuditLogRequest) (*auditV1.ApiAuditLog, error) {
	return nil, auditV1.ErrorNotFound("ApiAuditLog not found")
}

// Create records a new ApiAuditLog entry.
func (s *ApiAuditLogService) Create(ctx context.Context, req *auditV1.CreateApiAuditLogRequest) (*emptypb.Empty, error) {
	if req == nil || req.Data == nil {
		return nil, auditV1.ErrorBadRequest("invalid request")
	}
	// Use the repo's ent client to create the record
	// Audit logs are write-only system records, no need for viewer context
	err := s.repo.Create(ctx, req)
	if err != nil {
		s.log.Errorf("create ApiAuditLog failed: %s", err.Error())
		return nil, auditV1.ErrorInternalServerError("create ApiAuditLog failed")
	}
	return &emptypb.Empty{}, nil
}
