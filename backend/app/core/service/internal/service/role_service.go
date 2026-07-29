package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-ledger/app/core/service/internal/data"

	permissionV1 "go-wind-ledger/api/gen/go/permission/service/v1"
)

type RoleService struct {
	permissionV1.UnimplementedRoleServiceServer
	repo *data.RoleRepo
	log  *log.Helper
}

func NewRoleService(ctx *bootstrap.Context, repo *data.RoleRepo) *RoleService {
	return &RoleService{
		log:  ctx.NewLoggerHelper("role/service/core-service"),
		repo: repo,
	}
}

func (s *RoleService) List(ctx context.Context, req *paginationV1.PagingRequest) (*permissionV1.ListRoleResponse, error) {
	return s.repo.List(ctx, req)
}
