package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-cms/app/core/service/internal/data"

	identityV1 "go-wind-cms/api/gen/go/identity/service/v1"
)

type OrgUnitService struct {
	identityV1.UnimplementedOrgUnitServiceServer
	repo *data.OrgUnitRepo
	log  *log.Helper
}

func NewOrgUnitService(ctx *bootstrap.Context, repo *data.OrgUnitRepo) *OrgUnitService {
	return &OrgUnitService{
		log:  ctx.NewLoggerHelper("OrgUnit/service/core-service"),
		repo: repo,
	}
}

func (s *OrgUnitService) List(ctx context.Context, req *paginationV1.PagingRequest) (*identityV1.ListOrgUnitResponse, error) {
	return s.repo.List(ctx, req)
}
