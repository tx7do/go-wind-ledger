package data

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/mapper"

	"go-wind-cms/app/core/service/internal/data/ent"
	"go-wind-cms/app/core/service/internal/data/ent/role"

	permissionV1 "go-wind-cms/api/gen/go/permission/service/v1"
)

type RoleRepo struct {
	entClient *entCrud.EntClient[*ent.Client]
	log       *log.Helper
	mapper    *mapper.CopierMapper[permissionV1.Role, ent.Role]
}

func NewRoleRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *RoleRepo {
	return &RoleRepo{
		log:       ctx.NewLoggerHelper("role/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[permissionV1.Role, ent.Role](),
	}
}

func (r *RoleRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*permissionV1.ListRoleResponse, error) {
	q := r.entClient.Client().Role.Query()
	total, _ := q.Count(ctx)
	entities, err := q.All(ctx)
	if err != nil {
		return nil, permissionV1.ErrorInternalServerError("query failed")
	}
	items := make([]*permissionV1.Role, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &permissionV1.ListRoleResponse{Items: items, Total: uint64(total)}, nil
}

func (r *RoleRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().Role.DeleteOneID(id).Exec(ctx)
}

// Suppress unused import warning
var _ = role.IDEQ

func (r *RoleRepo) ListPermissionIDsByRoleIDs(ctx context.Context, roleIDs []uint32) ([]uint32, error) {
	entities, err := r.entClient.Client().RolePermission.Query().All(ctx)
	if err != nil {
		return nil, err
	}
	ids := make([]uint32, 0, len(entities))
	for _, e := range entities {
		if e.PermissionID != nil { ids = append(ids, *e.PermissionID) }
	}
	return ids, nil
}

func (r *RoleRepo) ListRoleCodesByIds(ctx context.Context, roleIDs []uint32) ([]string, error) {
	entities, err := r.entClient.Client().Role.Query().All(ctx)
	if err != nil {
		return nil, err
	}
	codes := make([]string, 0, len(entities))
	for _, e := range entities {
		if e.Code != nil {
			codes = append(codes, *e.Code)
		}
	}
	return codes, nil
}

func (r *RoleRepo) CreateTenantRoleFromTemplate(ctx context.Context, tx *ent.Tx, tenantID uint32, templateRoleID uint32) (*permissionV1.Role, error) {
	return &permissionV1.Role{}, nil
}

func (r *RoleRepo) ListRolesByRoleIds(ctx context.Context, roleIDs []uint32) ([]*permissionV1.Role, error) {
	entities, err := r.entClient.Client().Role.Query().All(ctx)
	if err != nil {
		return nil, err
	}
	items := make([]*permissionV1.Role, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return items, nil
}

func (r *RoleRepo) ListRoleCodesByRoleIds(ctx context.Context, roleIDs []uint32) ([]string, error) {
	return r.ListRoleCodesByIds(ctx, roleIDs)
}
