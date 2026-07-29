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

// Get retrieves a LoginAuditLog by ID.
func (s *LoginAuditLogService) Get(ctx context.Context, req *auditV1.GetLoginAuditLogRequest) (*auditV1.LoginAuditLog, error) {
	return nil, auditV1.ErrorNotFound("LoginAuditLog not found")
}

// Create records a new LoginAuditLog entry.
func (s *LoginAuditLogService) Create(ctx context.Context, req *auditV1.CreateLoginAuditLogRequest) (*emptypb.Empty, error) {
	if req == nil || req.Data == nil {
		return nil, auditV1.ErrorBadRequest("invalid request")
	}
	// Use the repo's ent client to create the record
	// Audit logs are write-only system records, no need for viewer context
	err := s.repo.Create(ctx, req)
	if err != nil {
		s.log.Errorf("create LoginAuditLog failed: %s", err.Error())
		return nil, auditV1.ErrorInternalServerError("create LoginAuditLog failed")
	}
	return &emptypb.Empty{}, nil
}
