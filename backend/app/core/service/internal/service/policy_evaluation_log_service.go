package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-ledger/app/core/service/internal/data"

	permissionV1 "go-wind-ledger/api/gen/go/permission/service/v1"
)

type PolicyEvaluationLogService struct {
	permissionV1.UnimplementedPolicyEvaluationLogServiceServer
	repo *data.PolicyEvaluationLogRepo
	log  *log.Helper
}

func NewPolicyEvaluationLogService(ctx *bootstrap.Context, repo *data.PolicyEvaluationLogRepo) *PolicyEvaluationLogService {
	return &PolicyEvaluationLogService{
		log:  ctx.NewLoggerHelper("policy_evaluation_log/service/core-service"),
		repo: repo,
	}
}

func (s *PolicyEvaluationLogService) List(ctx context.Context, req *paginationV1.PagingRequest) (*permissionV1.ListPolicyEvaluationLogResponse, error) {
	return s.repo.List(ctx, req)
}
