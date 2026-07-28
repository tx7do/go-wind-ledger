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

	auditV1 "go-wind-cms/api/gen/go/audit/service/v1"
)

type LoginAuditLogRepo struct {
	entClient *entCrud.EntClient[*ent.Client]
	log       *log.Helper
	mapper    *mapper.CopierMapper[auditV1.LoginAuditLog, ent.LoginAuditLog]
}

func NewLoginAuditLogRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *LoginAuditLogRepo {
	return &LoginAuditLogRepo{
		log:       ctx.NewLoggerHelper("loginauditlog/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[auditV1.LoginAuditLog, ent.LoginAuditLog](),
	}
}

func (r *LoginAuditLogRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*auditV1.ListLoginAuditLogResponse, error) {
	q := r.entClient.Client().LoginAuditLog.Query()
	total, _ := q.Count(ctx)
	entities, err := q.All(ctx)
	if err != nil {
		return nil, auditV1.ErrorInternalServerError("query failed")
	}
	items := make([]*auditV1.LoginAuditLog, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &auditV1.ListLoginAuditLogResponse{Items: items, Total: uint64(total)}, nil
}

func (r *LoginAuditLogRepo) Create(ctx context.Context, data *auditV1.LoginAuditLog) (*auditV1.LoginAuditLog, error) {
	saved, err := r.entClient.Client().LoginAuditLog.Create().
		SetCreatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return nil, auditV1.ErrorInternalServerError("create failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *LoginAuditLogRepo) Get(ctx context.Context, id uint32) (*auditV1.LoginAuditLog, error) {
	entity, err := r.entClient.Client().LoginAuditLog.Query().Where(func(s *sql.Selector) { s.Where(sql.EQ(s.C("id"), id)) }).Only(ctx)
	if err != nil {
		return nil, err
	}
	return r.mapper.ToDTO(entity), nil
}
