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

	"go-wind-cms/app/core/service/internal/data/ent"
	"go-wind-cms/app/core/service/internal/data/ent/payee"
	"go-wind-cms/app/core/service/internal/data/ent/predicate"

	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type PayeeRepo struct {
	entClient  *entCrud.EntClient[*ent.Client]
	log        *log.Helper
	mapper     *mapper.CopierMapper[ledgerV1.Payee, ent.Payee]
	repository *entCrud.Repository[
		ent.PayeeQuery, ent.PayeeSelect,
		ent.PayeeCreate, ent.PayeeCreateBulk,
		ent.PayeeUpdate, ent.PayeeUpdateOne,
		ent.PayeeDelete,
		predicate.Payee,
		ledgerV1.Payee, ent.Payee,
	]
}

func NewPayeeRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *PayeeRepo {
	repo := &PayeeRepo{
		log:       ctx.NewLoggerHelper("payee/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[ledgerV1.Payee, ent.Payee](),
	}
	repo.init()
	return repo
}

func (r *PayeeRepo) init() {
	r.repository = entCrud.NewRepository[
		ent.PayeeQuery, ent.PayeeSelect,
		ent.PayeeCreate, ent.PayeeCreateBulk,
		ent.PayeeUpdate, ent.PayeeUpdateOne,
		ent.PayeeDelete,
		predicate.Payee,
		ledgerV1.Payee, ent.Payee,
	](r.mapper)
	r.mapper.AppendConverters(copierutil.NewTimeStringConverterPair())
	r.mapper.AppendConverters(copierutil.NewTimeTimestamppbConverterPair())
}

func (r *PayeeRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListPayeeResponse, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Payee.Query()
	ret, err := r.repository.ListWithPaging(ctx, builder, builder.Clone(), req)
	if err != nil {
		return nil, err
	}
	if ret == nil {
		return &ledgerV1.ListPayeeResponse{Total: 0}, nil
	}
	return &ledgerV1.ListPayeeResponse{Total: ret.Total, Items: ret.Items}, nil
}

func (r *PayeeRepo) ListAll(ctx context.Context, bookID uint32) (*ledgerV1.ListPayeeResponse, error) {
	q := r.entClient.Client().Payee.Query().Where(payee.BookIDEQ(bookID), payee.EnableEQ(true))
	entities, err := q.All(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query payees failed")
	}
	items := make([]*ledgerV1.Payee, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &ledgerV1.ListPayeeResponse{Items: items, Total: uint64(len(items))}, nil
}

func (r *PayeeRepo) Get(ctx context.Context, id uint32) (*ledgerV1.Payee, error) {
	entity, err := r.entClient.Client().Payee.Query().Where(payee.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("payee not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get payee failed")
	}
	return r.mapper.ToDTO(entity), nil
}

func (r *PayeeRepo) Create(ctx context.Context, data *ledgerV1.Payee) (*ledgerV1.Payee, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	saved, err := r.entClient.Client().Payee.Create().
		SetNillableBookID(data.BookId).
		SetNillableName(data.Name).
		SetNillableNotes(data.Notes).
		SetNillableEnable(data.Enable).
		SetNillableCanExpense(data.CanExpense).
		SetNillableCanIncome(data.CanIncome).
		SetNillableCreatedBy(data.CreatedBy).
		SetCreatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("create payee failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *PayeeRepo) Update(ctx context.Context, id uint32, data *ledgerV1.Payee, mask *fieldmaskpb.FieldMask) (*ledgerV1.Payee, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	updated, err := r.entClient.Client().Payee.UpdateOneID(id).
		SetNillableName(data.Name).
		SetNillableNotes(data.Notes).
		SetNillableEnable(data.Enable).
		SetNillableCanExpense(data.CanExpense).
		SetNillableCanIncome(data.CanIncome).
		SetNillableUpdatedBy(data.UpdatedBy).
		SetUpdatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("update payee failed")
	}
	return r.mapper.ToDTO(updated), nil
}

func (r *PayeeRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().Payee.DeleteOneID(id).Exec(ctx)
}

func (r *PayeeRepo) Toggle(ctx context.Context, id uint32) (*ledgerV1.Payee, error) {
	entity, err := r.entClient.Client().Payee.Query().Where(payee.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("payee not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get payee failed")
	}
	updated, _ := r.entClient.Client().Payee.UpdateOneID(id).SetEnable(!*entity.Enable).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}
