package data

import (
	"context"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/copierutil"
	"github.com/tx7do/go-utils/mapper"

	"go-wind-ledger/app/core/service/internal/data/ent"
	"go-wind-ledger/app/core/service/internal/data/ent/noteday"
	"go-wind-ledger/app/core/service/internal/data/ent/predicate"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

type NoteDayRepo struct {
	entClient  *entCrud.EntClient[*ent.Client]
	log        *log.Helper
	mapper     *mapper.CopierMapper[ledgerV1.NoteDay, ent.NoteDay]
	repository *entCrud.Repository[
		ent.NoteDayQuery, ent.NoteDaySelect,
		ent.NoteDayCreate, ent.NoteDayCreateBulk,
		ent.NoteDayUpdate, ent.NoteDayUpdateOne,
		ent.NoteDayDelete,
		predicate.NoteDay,
		ledgerV1.NoteDay, ent.NoteDay,
	]
}

func NewNoteDayRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *NoteDayRepo {
	repo := &NoteDayRepo{
		log:       ctx.NewLoggerHelper("noteday/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[ledgerV1.NoteDay, ent.NoteDay](),
	}
	repo.init()
	return repo
}

func (r *NoteDayRepo) init() {
	r.repository = entCrud.NewRepository[
		ent.NoteDayQuery, ent.NoteDaySelect,
		ent.NoteDayCreate, ent.NoteDayCreateBulk,
		ent.NoteDayUpdate, ent.NoteDayUpdateOne,
		ent.NoteDayDelete,
		predicate.NoteDay,
		ledgerV1.NoteDay, ent.NoteDay,
	](r.mapper)
	r.mapper.AppendConverters(copierutil.NewTimeStringConverterPair())
	r.mapper.AppendConverters(copierutil.NewTimeTimestamppbConverterPair())
}

func (r *NoteDayRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListNoteDayResponse, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().NoteDay.Query()
	ret, err := r.repository.ListWithPaging(ctx, builder, builder.Clone(), req)
	if err != nil {
		return nil, err
	}
	if ret == nil {
		return &ledgerV1.ListNoteDayResponse{Total: 0}, nil
	}
	return &ledgerV1.ListNoteDayResponse{Total: ret.Total, Items: ret.Items}, nil
}

func (r *NoteDayRepo) Get(ctx context.Context, id uint32) (*ledgerV1.NoteDay, error) {
	entity, err := r.entClient.Client().NoteDay.Query().Where(noteday.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("note day not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get note day failed")
	}
	return r.mapper.ToDTO(entity), nil
}

func (r *NoteDayRepo) Create(ctx context.Context, data *ledgerV1.NoteDay) (*ledgerV1.NoteDay, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	saved, err := r.entClient.Client().NoteDay.Create().
		SetNillableUserID(data.UserId).
		SetNillableTitle(data.Title).
		SetNillableNotes(data.Notes).
		SetNillableStartDate(data.StartDate).
		SetNillableEndDate(data.EndDate).
		SetNillableNextDate(data.NextDate).
		SetNillableRepeatType(data.RepeatType).
		SetNillableInterval(data.Interval).
		SetNillableTotalCount(data.TotalCount).
		SetNillableRunCount(data.RunCount).
		SetNillableCreatedBy(data.CreatedBy).
		SetCreatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("create note day failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *NoteDayRepo) Update(ctx context.Context, id uint32, data *ledgerV1.NoteDay, mask *fieldmaskpb.FieldMask) (*ledgerV1.NoteDay, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	updated, err := r.entClient.Client().NoteDay.UpdateOneID(id).
		SetNillableTitle(data.Title).
		SetNillableNotes(data.Notes).
		SetNillableStartDate(data.StartDate).
		SetNillableEndDate(data.EndDate).
		SetNillableNextDate(data.NextDate).
		SetNillableRepeatType(data.RepeatType).
		SetNillableInterval(data.Interval).
		SetNillableTotalCount(data.TotalCount).
		SetNillableRunCount(data.RunCount).
		SetNillableUpdatedBy(data.UpdatedBy).
		SetUpdatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("update note day failed")
	}
	return r.mapper.ToDTO(updated), nil
}

func (r *NoteDayRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().NoteDay.DeleteOneID(id).Exec(ctx)
}

func (r *NoteDayRepo) UpdateNextDate(ctx context.Context, id uint32, nextDate int64, runCount int32) error {
	_, err := r.entClient.Client().NoteDay.UpdateOneID(id).
		SetNextDate(nextDate).SetRunCount(runCount).Save(ctx)
	return err
}
