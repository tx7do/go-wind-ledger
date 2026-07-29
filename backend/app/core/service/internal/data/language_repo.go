package data

import (
	"context"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/mapper"

	"go-wind-ledger/app/core/service/internal/data/ent"
	"go-wind-ledger/app/core/service/internal/data/ent/language"

	dictV1 "go-wind-ledger/api/gen/go/dict/service/v1"
)

type LanguageRepo struct {
	entClient *entCrud.EntClient[*ent.Client]
	log       *log.Helper
	mapper    *mapper.CopierMapper[dictV1.Language, ent.Language]
}

func NewLanguageRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *LanguageRepo {
	return &LanguageRepo{
		log:       ctx.NewLoggerHelper("language/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[dictV1.Language, ent.Language](),
	}
}

func (r *LanguageRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*dictV1.ListLanguageResponse, error) {
	q := r.entClient.Client().Language.Query()
	total, _ := q.Count(ctx)
	entities, err := q.All(ctx)
	if err != nil {
		return nil, dictV1.ErrorInternalServerError("query languages failed")
	}
	items := make([]*dictV1.Language, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &dictV1.ListLanguageResponse{Items: items, Total: uint64(total)}, nil
}

func (r *LanguageRepo) Get(ctx context.Context, id uint32) (*dictV1.Language, error) {
	entity, err := r.entClient.Client().Language.Query().Where(language.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, dictV1.ErrorNotFound("language not found")
		}
		return nil, dictV1.ErrorInternalServerError("get language failed")
	}
	return r.mapper.ToDTO(entity), nil
}

func (r *LanguageRepo) Create(ctx context.Context, data *dictV1.Language) (*dictV1.Language, error) {
	saved, err := r.entClient.Client().Language.Create().
		SetNillableCode(data.LanguageCode).
		SetNillableName(data.LanguageName).
		SetNillableEnable(data.IsEnabled).
		SetCreatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return nil, dictV1.ErrorInternalServerError("create language failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *LanguageRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().Language.DeleteOneID(id).Exec(ctx)
}
