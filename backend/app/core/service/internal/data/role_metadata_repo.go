package data

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/mapper"

	"go-wind-ledger/app/core/service/internal/data/ent"
	"go-wind-ledger/app/core/service/internal/data/ent/rolemetadata"

	permissionV1 "go-wind-ledger/api/gen/go/permission/service/v1"
)

type RoleMetadataRepo struct {
	entClient *entCrud.EntClient[*ent.Client]
	log       *log.Helper
	mapper    *mapper.CopierMapper[permissionV1.Role, ent.RoleMetadata]
}

func NewRoleMetadataRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *RoleMetadataRepo {
	return &RoleMetadataRepo{
		log:       ctx.NewLoggerHelper("rolemetadata/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[permissionV1.Role, ent.RoleMetadata](),
	}
}

func (r *RoleMetadataRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*permissionV1.ListRoleResponse, error) {
	q := r.entClient.Client().RoleMetadata.Query()
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

func (r *RoleMetadataRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().RoleMetadata.DeleteOneID(id).Exec(ctx)
}

// Suppress unused import warning
var _ = rolemetadata.IDEQ
