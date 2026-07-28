package data

import (
	"context"
	"entgo.io/ent/dialect/sql"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/mapper"

	"go-wind-cms/app/core/service/internal/data/ent"

	permissionV1 "go-wind-cms/api/gen/go/permission/service/v1"
)

type PolicyEvaluationLogRepo struct {
	entClient *entCrud.EntClient[*ent.Client]
	log       *log.Helper
	mapper    *mapper.CopierMapper[permissionV1.PolicyEvaluationLog, ent.PolicyEvaluationLog]
}

func NewPolicyEvaluationLogRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *PolicyEvaluationLogRepo {
	return &PolicyEvaluationLogRepo{
		log:       ctx.NewLoggerHelper("policyevaluationlog/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[permissionV1.PolicyEvaluationLog, ent.PolicyEvaluationLog](),
	}
}

func (r *PolicyEvaluationLogRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*permissionV1.ListPolicyEvaluationLogResponse, error) {
	q := r.entClient.Client().PolicyEvaluationLog.Query()
	total, _ := q.Count(ctx)
	entities, err := q.All(ctx)
	if err != nil {
		return nil, permissionV1.ErrorInternalServerError("query failed")
	}
	items := make([]*permissionV1.PolicyEvaluationLog, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &permissionV1.ListPolicyEvaluationLogResponse{Items: items, Total: uint64(total)}, nil
}

func (r *PolicyEvaluationLogRepo) Create(ctx context.Context, data *permissionV1.PolicyEvaluationLog) (*permissionV1.PolicyEvaluationLog, error) {
	saved, err := r.entClient.Client().PolicyEvaluationLog.Create().
		SetCreatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return nil, permissionV1.ErrorInternalServerError("create failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *PolicyEvaluationLogRepo) Get(ctx context.Context, id uint32) (*permissionV1.PolicyEvaluationLog, error) {
	entity, err := r.entClient.Client().PolicyEvaluationLog.Query().Where(func(s *sql.Selector) { s.Where(sql.EQ(s.C("id"), id)) }).Only(ctx)
	if err != nil {
		return nil, err
	}
	return r.mapper.ToDTO(entity), nil
}
