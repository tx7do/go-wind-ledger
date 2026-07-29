package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-ledger/app/core/service/internal/data"

	identityV1 "go-wind-ledger/api/gen/go/identity/service/v1"
)

type PositionService struct {
	identityV1.UnimplementedPositionServiceServer
	repo *data.PositionRepo
	log  *log.Helper
}

func NewPositionService(ctx *bootstrap.Context, repo *data.PositionRepo) *PositionService {
	return &PositionService{
		log:  ctx.NewLoggerHelper("position/service/core-service"),
		repo: repo,
	}
}

func (s *PositionService) List(ctx context.Context, req *paginationV1.PagingRequest) (*identityV1.ListPositionResponse, error) {
	return s.repo.List(ctx, req)
}
