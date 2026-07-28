package data

import (
	"context"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"github.com/tx7do/go-utils/mapper"

	entCrud "github.com/tx7do/go-crud/entgo"

	"go-wind-cms/app/core/service/internal/data/ent"
	"go-wind-cms/app/core/service/internal/data/ent/flowfile"

	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type FlowFileRepo struct {
	entClient *entCrud.EntClient[*ent.Client]
	log       *log.Helper
	mapper    *mapper.CopierMapper[ledgerV1.FlowFile, ent.FlowFile]
}

func NewFlowFileRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *FlowFileRepo {
	return &FlowFileRepo{
		entClient: entClient,
		log:       ctx.NewLoggerHelper("flowfile/repo/core-service"),
		mapper:    mapper.NewCopierMapper[ledgerV1.FlowFile, ent.FlowFile](),
	}
}

func (r *FlowFileRepo) ListByFlow(ctx context.Context, flowID uint32) ([]*ledgerV1.FlowFile, error) {
	entities, err := r.entClient.Client().FlowFile.Query().Where(flowfile.FlowIDEQ(flowID)).All(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query flow files failed")
	}
	list := make([]*ledgerV1.FlowFile, 0, len(entities))
	for _, e := range entities {
		list = append(list, r.mapper.ToDTO(e))
	}
	return list, nil
}

func (r *FlowFileRepo) Create(ctx context.Context, data *ledgerV1.FlowFile) (*ledgerV1.FlowFile, error) {
	saved, err := r.entClient.Client().FlowFile.Create().
		SetNillableFlowID(data.FlowId).
		SetNillableCreatorID(data.CreatorId).
		SetNillableCreateTime(data.CreateTime).
		SetNillableContentType(data.ContentType).
		SetNillableSize(data.Size).
		SetNillableOriginalName(data.OriginalName).
		SetCreatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("create flow file failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *FlowFileRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().FlowFile.DeleteOneID(id).Exec(ctx)
}

func (r *FlowFileRepo) DeleteByFlow(ctx context.Context, flowID uint32) error {
	_, err := r.entClient.Client().FlowFile.Delete().Where(flowfile.FlowIDEQ(flowID)).Exec(ctx)
	return err
}

// ReassignFlow updates all attachments from one flow to another (used by BalanceFlow Update).
func (r *FlowFileRepo) ReassignFlow(ctx context.Context, oldFlowID uint32, newFlowID uint32) error {
	_, err := r.entClient.Client().FlowFile.Update().
		Where(flowfile.FlowIDEQ(oldFlowID)).
		SetFlowID(newFlowID).
		Save(ctx)
	return err
}
