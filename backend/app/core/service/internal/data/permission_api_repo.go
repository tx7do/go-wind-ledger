package data

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/mapper"

	"go-wind-cms/app/core/service/internal/data/ent"

	permissionV1 "go-wind-cms/api/gen/go/permission/service/v1"
)

type PermissionApiRepo struct {
	entClient *entCrud.EntClient[*ent.Client]
	log       *log.Helper
	mapper    *mapper.CopierMapper[permissionV1.Permission, ent.PermissionApi]
}

func NewPermissionApiRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *PermissionApiRepo {
	return &PermissionApiRepo{
		log:       ctx.NewLoggerHelper("permission-api/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[permissionV1.Permission, ent.PermissionApi](),
	}
}

func (r *PermissionApiRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*permissionV1.ListPermissionResponse, error) {
	q := r.entClient.Client().PermissionApi.Query()
	total, _ := q.Count(ctx)
	entities, err := q.All(ctx)
	if err != nil {
		return nil, permissionV1.ErrorInternalServerError("query failed")
	}
	items := make([]*permissionV1.Permission, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &permissionV1.ListPermissionResponse{Items: items, Total: uint64(total)}, nil
}

func (r *PermissionApiRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().PermissionApi.DeleteOneID(id).Exec(ctx)
}

func (r *PermissionApiRepo) ListApiIDs(ctx context.Context, permissionIDs []uint32) ([]uint32, error) {
	entities, err := r.entClient.Client().PermissionApi.Query().All(ctx)
	if err != nil {
		return nil, err
	}
	ids := make([]uint32, 0, len(entities))
	for _, e := range entities {
		ids = append(ids, e.ID)
	}
	return ids, nil
}

func (r *PermissionApiRepo) AssignApis(ctx context.Context, permissionID uint32, apiIDs []uint32) error {
	for range apiIDs {
		_, err := r.entClient.Client().PermissionApi.Create().SetPermissionID(permissionID).Save(ctx)
		if err != nil {
			return err
		}
	}
	return nil
}

func (r *PermissionApiRepo) DeleteByPermissionIDs(ctx context.Context, permissionIDs []uint32) error {
	_, err := r.entClient.Client().PermissionApi.Delete().Exec(ctx)
	return err
}

func (r *PermissionApiRepo) Truncate(ctx context.Context, permissionID ...uint32) error {
	_, err := r.entClient.Client().PermissionApi.Delete().Exec(ctx)
	return err
}
