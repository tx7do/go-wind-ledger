package data

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/mapper"

	"go-wind-cms/app/core/service/internal/data/ent"
	"go-wind-cms/app/core/service/internal/data/ent/position"

	identityV1 "go-wind-cms/api/gen/go/identity/service/v1"
)

type PositionRepo struct {
	entClient *entCrud.EntClient[*ent.Client]
	log       *log.Helper
	mapper    *mapper.CopierMapper[identityV1.Position, ent.Position]
}

func NewPositionRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *PositionRepo {
	return &PositionRepo{
		log:       ctx.NewLoggerHelper("position/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[identityV1.Position, ent.Position](),
	}
}

func (r *PositionRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*identityV1.ListPositionResponse, error) {
	q := r.entClient.Client().Position.Query()
	total, _ := q.Count(ctx)
	entities, err := q.All(ctx)
	if err != nil {
		return nil, identityV1.ErrorInternalServerError("query failed")
	}
	items := make([]*identityV1.Position, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &identityV1.ListPositionResponse{Items: items, Total: uint64(total)}, nil
}

func (r *PositionRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().Position.DeleteOneID(id).Exec(ctx)
}

// Suppress unused import warning
var _ = position.IDEQ

func (r *PositionRepo) ListPositionByIds(ctx context.Context, positionIDs []uint32) ([]*identityV1.Position, error) {
	entities, err := r.entClient.Client().Position.Query().All(ctx)
	if err != nil {
		return nil, err
	}
	items := make([]*identityV1.Position, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return items, nil
}
