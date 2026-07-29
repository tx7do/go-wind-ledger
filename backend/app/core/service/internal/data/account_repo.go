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
	"go-wind-cms/app/core/service/internal/data/ent/account"
	"go-wind-cms/app/core/service/internal/data/ent/predicate"

	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type AccountRepo struct {
	entClient  *entCrud.EntClient[*ent.Client]
	log        *log.Helper
	mapper     *mapper.CopierMapper[ledgerV1.Account, ent.Account]
	repository *entCrud.Repository[
		ent.AccountQuery, ent.AccountSelect,
		ent.AccountCreate, ent.AccountCreateBulk,
		ent.AccountUpdate, ent.AccountUpdateOne,
		ent.AccountDelete,
		predicate.Account,
		ledgerV1.Account, ent.Account,
	]
}

func NewAccountRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *AccountRepo {
	repo := &AccountRepo{
		log:       ctx.NewLoggerHelper("account/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[ledgerV1.Account, ent.Account](),
	}
	repo.init()
	return repo
}

func (r *AccountRepo) init() {
	r.repository = entCrud.NewRepository[
		ent.AccountQuery, ent.AccountSelect,
		ent.AccountCreate, ent.AccountCreateBulk,
		ent.AccountUpdate, ent.AccountUpdateOne,
		ent.AccountDelete,
		predicate.Account,
		ledgerV1.Account, ent.Account,
	](r.mapper)
	r.mapper.AppendConverters(copierutil.NewTimeStringConverterPair())
	r.mapper.AppendConverters(copierutil.NewTimeTimestamppbConverterPair())
}

func (r *AccountRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListAccountResponse, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Account.Query()
	ret, err := r.repository.ListWithPaging(ctx, builder, builder.Clone(), req)
	if err != nil {
		return nil, err
	}
	if ret == nil {
		return &ledgerV1.ListAccountResponse{Total: 0}, nil
	}
	return &ledgerV1.ListAccountResponse{Total: ret.Total, Items: ret.Items}, nil
}

func (r *AccountRepo) ListAll(ctx context.Context, includeDisabled bool) (*ledgerV1.ListAccountResponse, error) {
	q := r.entClient.Client().Account.Query()
	if !includeDisabled {
		q = q.Where(account.EnableEQ(true))
	}
	entities, err := q.All(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query accounts failed")
	}
	items := make([]*ledgerV1.Account, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &ledgerV1.ListAccountResponse{Items: items, Total: uint64(len(items))}, nil
}

func (r *AccountRepo) Get(ctx context.Context, id uint32) (*ledgerV1.Account, error) {
	entity, err := r.entClient.Client().Account.Query().Where(account.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("account not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get account failed")
	}
	return r.mapper.ToDTO(entity), nil
}

func (r *AccountRepo) Create(ctx context.Context, data *ledgerV1.Account) (*ledgerV1.Account, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Account.Create().
		SetNillableName(data.Name).
		SetNillableBalance(strPtrToFloatPtr(data.Balance)).
		SetNillableInitialBalance(strPtrToFloatPtr(data.InitialBalance)).
		SetNillableCreditLimit(strPtrToFloatPtr(data.CreditLimit)).
		SetNillableBillDay(data.BillDay).
		SetNillableApr(strPtrToFloatPtr(data.Apr)).
		SetNillableCurrencyCode(data.CurrencyCode).
		SetNillableNo(data.No).
		SetNillableInclude(data.Include).
		SetNillableCanExpense(data.CanExpense).
		SetNillableCanIncome(data.CanIncome).
		SetNillableCanTransferFrom(data.CanTransferFrom).
		SetNillableCanTransferTo(data.CanTransferTo).
		SetNillableNotes(data.Notes).
		SetNillableEnable(data.Enable).
		SetNillableCreatedBy(data.CreatedBy).
		SetCreatedAt(time.Now())

	if data.Type != nil {
		builder = builder.SetType(account.Type(data.Type.String()))
	}

	saved, err := builder.Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("create account failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *AccountRepo) Update(ctx context.Context, id uint32, data *ledgerV1.Account, mask *fieldmaskpb.FieldMask) (*ledgerV1.Account, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Account.UpdateOneID(id).
		SetNillableName(data.Name).
		SetNillableInitialBalance(strPtrToFloatPtr(data.InitialBalance)).
		SetNillableCreditLimit(strPtrToFloatPtr(data.CreditLimit)).
		SetNillableBillDay(data.BillDay).
		SetNillableApr(strPtrToFloatPtr(data.Apr)).
		SetNillableNo(data.No).
		SetNillableInclude(data.Include).
		SetNillableCanExpense(data.CanExpense).
		SetNillableCanIncome(data.CanIncome).
		SetNillableCanTransferFrom(data.CanTransferFrom).
		SetNillableCanTransferTo(data.CanTransferTo).
		SetNillableNotes(data.Notes).
		SetNillableEnable(data.Enable).
		SetNillableUpdatedBy(data.UpdatedBy).
		SetUpdatedAt(time.Now())

	updated, err := builder.Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("update account failed")
	}
	return r.mapper.ToDTO(updated), nil
}

func (r *AccountRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().Account.DeleteOneID(id).Exec(ctx)
}

func (r *AccountRepo) Toggle(ctx context.Context, id uint32) (*ledgerV1.Account, error) {
	entity, err := r.entClient.Client().Account.Query().Where(account.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("account not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get account failed")
	}
	updated, _ := r.entClient.Client().Account.UpdateOneID(id).SetEnable(!*entity.Enable).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}

func (r *AccountRepo) ToggleInclude(ctx context.Context, id uint32) (*ledgerV1.Account, error) {
	entity, err := r.entClient.Client().Account.Query().Where(account.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("account not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get account failed")
	}
	updated, _ := r.entClient.Client().Account.UpdateOneID(id).SetInclude(!*entity.Include).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}

func (r *AccountRepo) ToggleCanExpense(ctx context.Context, id uint32) (*ledgerV1.Account, error) {
	entity, err := r.entClient.Client().Account.Query().Where(account.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("account not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get account failed")
	}
	updated, _ := r.entClient.Client().Account.UpdateOneID(id).SetCanExpense(!*entity.CanExpense).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}

func (r *AccountRepo) ToggleCanIncome(ctx context.Context, id uint32) (*ledgerV1.Account, error) {
	entity, err := r.entClient.Client().Account.Query().Where(account.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("account not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get account failed")
	}
	updated, _ := r.entClient.Client().Account.UpdateOneID(id).SetCanIncome(!*entity.CanIncome).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}

func (r *AccountRepo) ToggleCanTransferFrom(ctx context.Context, id uint32) (*ledgerV1.Account, error) {
	entity, err := r.entClient.Client().Account.Query().Where(account.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("account not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get account failed")
	}
	updated, _ := r.entClient.Client().Account.UpdateOneID(id).SetCanTransferFrom(!*entity.CanTransferFrom).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}

func (r *AccountRepo) ToggleCanTransferTo(ctx context.Context, id uint32) (*ledgerV1.Account, error) {
	entity, err := r.entClient.Client().Account.Query().Where(account.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("account not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get account failed")
	}
	updated, _ := r.entClient.Client().Account.UpdateOneID(id).SetCanTransferTo(!*entity.CanTransferTo).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}

func (r *AccountRepo) UpdateBalance(ctx context.Context, id uint32, newBalance float64) error {
	_, err := r.entClient.Client().Account.UpdateOneID(id).SetBalance(newBalance).Save(ctx)
	return err
}

