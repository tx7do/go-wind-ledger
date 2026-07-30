package data

import (
	"context"
	"time"

	"entgo.io/ent/dialect/sql"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/copierutil"
	"github.com/tx7do/go-utils/mapper"

	"go-wind-ledger/app/core/service/internal/data/ent"
	"go-wind-ledger/app/core/service/internal/data/ent/account"
	"go-wind-ledger/app/core/service/internal/data/ent/balanceflow"
	"go-wind-ledger/app/core/service/internal/data/ent/categoryrelation"
	"go-wind-ledger/app/core/service/internal/data/ent/predicate"
	"go-wind-ledger/app/core/service/internal/data/ent/tagrelation"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

type BalanceFlowRepo struct {
	entClient  *entCrud.EntClient[*ent.Client]
	log        *log.Helper
	mapper     *mapper.CopierMapper[ledgerV1.BalanceFlow, ent.BalanceFlow]
	repository *entCrud.Repository[
		ent.BalanceFlowQuery, ent.BalanceFlowSelect,
		ent.BalanceFlowCreate, ent.BalanceFlowCreateBulk,
		ent.BalanceFlowUpdate, ent.BalanceFlowUpdateOne,
		ent.BalanceFlowDelete,
		predicate.BalanceFlow,
		ledgerV1.BalanceFlow, ent.BalanceFlow,
	]
}

func NewBalanceFlowRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *BalanceFlowRepo {
	repo := &BalanceFlowRepo{
		log:       ctx.NewLoggerHelper("balanceflow/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[ledgerV1.BalanceFlow, ent.BalanceFlow](),
	}
	repo.init()
	return repo
}

func (r *BalanceFlowRepo) init() {
	r.repository = entCrud.NewRepository[
		ent.BalanceFlowQuery, ent.BalanceFlowSelect,
		ent.BalanceFlowCreate, ent.BalanceFlowCreateBulk,
		ent.BalanceFlowUpdate, ent.BalanceFlowUpdateOne,
		ent.BalanceFlowDelete,
		predicate.BalanceFlow,
		ledgerV1.BalanceFlow, ent.BalanceFlow,
	](r.mapper)
	r.mapper.AppendConverters(copierutil.NewTimeStringConverterPair())
	r.mapper.AppendConverters(copierutil.NewTimeTimestamppbConverterPair())
	r.mapper.AppendConverters(float64StringConverters)
}

func (r *BalanceFlowRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListBalanceFlowResponse, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().BalanceFlow.Query()
	ret, err := r.repository.ListWithPaging(ctx, builder, builder.Clone(), req)
	if err != nil {
		return nil, err
	}
	if ret == nil {
		return &ledgerV1.ListBalanceFlowResponse{Total: 0}, nil
	}
	return &ledgerV1.ListBalanceFlowResponse{Total: ret.Total, Items: ret.Items}, nil
}

func (r *BalanceFlowRepo) Get(ctx context.Context, id uint32) (*ledgerV1.BalanceFlow, error) {
	entity, err := r.entClient.Client().BalanceFlow.Query().Where(balanceflow.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("balance flow not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get balance flow failed")
	}
	return r.mapper.ToDTO(entity), nil
}

// CreateFlow creates a balance flow.
func (r *BalanceFlowRepo) CreateFlow(ctx context.Context, data *ledgerV1.BalanceFlow) (*ledgerV1.BalanceFlow, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	now := time.Now().UnixMilli()
	builder := r.entClient.Client().BalanceFlow.Create().
		SetNillableBookID(data.BookId).
		SetNillableAmount(strPtrToFloatPtr(data.Amount)).
		SetNillableConvertedAmount(strPtrToFloatPtr(data.ConvertedAmount)).
		SetNillableAccountID(data.AccountId).
		SetNillableToAccountID(data.ToAccountId).
		SetNillablePayeeID(data.PayeeId).
		SetNillableCreatorID(data.CreatorId).
		SetNillableCreateTime(data.CreateTime).
		SetNillableTitle(data.Title).
		SetNillableNotes(data.Notes).
		SetNillableConfirm(data.Confirm).
		SetNillableInclude(data.Include).
		SetInsertAt(now).
		SetNillableCreatedBy(data.CreatedBy).
		SetCreatedAt(time.Now())

	if data.Type != nil {
		builder = builder.SetType(balanceflow.Type(data.Type.String()))
	}

	saved, err := builder.Save(ctx)
	if err != nil {
		r.log.Errorf("create balance flow failed: %s", err.Error())
		return nil, ledgerV1.ErrorInternalServerError("create balance flow failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *BalanceFlowRepo) Update(ctx context.Context, id uint32, data *ledgerV1.BalanceFlow, mask *fieldmaskpb.FieldMask) (*ledgerV1.BalanceFlow, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().BalanceFlow.UpdateOneID(id).
		SetUpdatedAt(time.Now())

	// Apply field updates based on FieldMask (or all fields if no mask)
	if mask == nil || len(mask.Paths) == 0 {
		builder = builder.
			SetNillableTitle(data.Title).
			SetNillableNotes(data.Notes)
	} else {
		for _, path := range mask.Paths {
			switch path {
			case "confirm":
				builder = builder.SetNillableConfirm(data.Confirm)
			case "title":
				builder = builder.SetNillableTitle(data.Title)
			case "notes":
				builder = builder.SetNillableNotes(data.Notes)
			case "include":
				builder = builder.SetNillableInclude(data.Include)
			case "amount":
				builder = builder.SetNillableAmount(strPtrToFloatPtr(data.Amount))
			case "converted_amount":
				builder = builder.SetNillableConvertedAmount(strPtrToFloatPtr(data.ConvertedAmount))
			case "account_id":
				builder = builder.SetNillableAccountID(data.AccountId)
			case "to_account_id":
				builder = builder.SetNillableToAccountID(data.ToAccountId)
			case "payee_id":
				builder = builder.SetNillablePayeeID(data.PayeeId)
			case "create_time":
				builder = builder.SetNillableCreateTime(data.CreateTime)
			}
		}
	}

	updated, err := builder.Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("update balance flow failed")
	}
	return r.mapper.ToDTO(updated), nil
}

func (r *BalanceFlowRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().BalanceFlow.DeleteOneID(id).Exec(ctx)
}

// === Core Accounting Logic ===

// ConfirmBalance updates account balances based on flow type.
func (r *BalanceFlowRepo) ConfirmBalance(ctx context.Context, flow *ledgerV1.BalanceFlow) error {
	if !flow.GetConfirm() || flow.GetAccountId() == 0 {
		return nil
	}
	amount := StrToFloat(flow.GetAmount())
	convertedAmount := StrToFloat(flow.GetConvertedAmount())

	switch flow.GetType() {
	case ledgerV1.FlowType_FLOW_TYPE_EXPENSE:
		return r.entClient.Client().Account.UpdateOneID(flow.GetAccountId()).
			AddBalance(-amount).Exec(ctx)
	case ledgerV1.FlowType_FLOW_TYPE_INCOME:
		return r.entClient.Client().Account.UpdateOneID(flow.GetAccountId()).
			AddBalance(amount).Exec(ctx)
	case ledgerV1.FlowType_FLOW_TYPE_TRANSFER:
		if err := r.entClient.Client().Account.UpdateOneID(flow.GetAccountId()).
			AddBalance(-amount).Exec(ctx); err != nil {
			return err
		}
		return r.entClient.Client().Account.UpdateOneID(flow.GetToAccountId()).
			AddBalance(convertedAmount).Exec(ctx)
	case ledgerV1.FlowType_FLOW_TYPE_ADJUST:
		return r.entClient.Client().Account.UpdateOneID(flow.GetAccountId()).
			SetBalance(amount).Exec(ctx)
	}
	return nil
}

// RefundBalance reverses confirmBalance when deleting a flow.
func (r *BalanceFlowRepo) RefundBalance(ctx context.Context, flow *ent.BalanceFlow) error {
	if flow.Confirm == nil || !*flow.Confirm || flow.AccountID == nil {
		return nil
	}
	amount := 0.0
	if flow.Amount != nil {
		amount = *flow.Amount
	}
	switch *flow.Type {
	case balanceflow.TypeFlowTypeExpense:
		return r.entClient.Client().Account.UpdateOneID(*flow.AccountID).
			AddBalance(amount).Exec(ctx)
	case balanceflow.TypeFlowTypeIncome:
		return r.entClient.Client().Account.UpdateOneID(*flow.AccountID).
			AddBalance(-amount).Exec(ctx)
	case balanceflow.TypeFlowTypeTransfer:
		if err := r.entClient.Client().Account.UpdateOneID(*flow.AccountID).
			AddBalance(amount).Exec(ctx); err != nil {
			return err
		}
		converted := 0.0
		if flow.ConvertedAmount != nil {
			converted = *flow.ConvertedAmount
		}
		return r.entClient.Client().Account.UpdateOneID(*flow.ToAccountID).
			AddBalance(-converted).Exec(ctx)
	case balanceflow.TypeFlowTypeAdjust:
		r.log.Warnf("cannot properly refund ADJUST flow id=%d", flow.ID)
		return nil
	}
	return nil
}

// Statistics computes [expense, income, net] for the given book.
//
// book_id 作用域与 List 保持一致：当 bookID 为 0（调用方未指定，例如前端统计接口未传
// bookId）时不施加 book 过滤，避免 WHERE book_id = 0 把所有真实流水（book_id != 0）
// 排除在外导致统计恒为 0。多账本作用域的收口应通过鉴权层统一注入，不应在此处默认按 0 过滤。
func (r *BalanceFlowRepo) Statistics(ctx context.Context, bookID uint32, confirmedOnly bool) (expense, income, net float64, err error) {
	baseQuery := r.entClient.Client().BalanceFlow.Query()
	if bookID != 0 {
		baseQuery = baseQuery.Where(balanceflow.BookIDEQ(bookID))
	}
	if confirmedOnly {
		baseQuery = baseQuery.Where(balanceflow.ConfirmEQ(true))
	}

	var expenseResult []struct {
		Sum float64 `json:"sum"`
	}
	expenseErr := baseQuery.Clone().
		Where(balanceflow.TypeEQ(balanceflow.TypeFlowTypeExpense)).
		Aggregate(ent.Sum(balanceflow.FieldConvertedAmount)).
		Scan(ctx, &expenseResult)
	if expenseErr != nil {
		r.log.Errorf("query expense sum failed: %s", expenseErr.Error())
		return 0, 0, 0, ledgerV1.ErrorInternalServerError("query expense statistics failed")
	}
	if len(expenseResult) > 0 {
		expense = expenseResult[0].Sum
	}

	var incomeResult []struct {
		Sum float64 `json:"sum"`
	}
	incomeErr := baseQuery.Clone().
		Where(balanceflow.TypeEQ(balanceflow.TypeFlowTypeIncome)).
		Aggregate(ent.Sum(balanceflow.FieldConvertedAmount)).
		Scan(ctx, &incomeResult)
	if incomeErr != nil {
		r.log.Errorf("query income sum failed: %s", incomeErr.Error())
		return 0, 0, 0, ledgerV1.ErrorInternalServerError("query income statistics failed")
	}
	if len(incomeResult) > 0 {
		income = incomeResult[0].Sum
	}

	net = income - expense
	return
}

func (r *BalanceFlowRepo) UpdateAccountBalance(ctx context.Context, accountID uint32, newBalance float64) error {
	return r.entClient.Client().Account.UpdateOneID(accountID).SetBalance(newBalance).Exec(ctx)
}

func (r *BalanceFlowRepo) GetAccount(ctx context.Context, accountID uint32) (*ent.Account, error) {
	return r.entClient.Client().Account.Query().Where(account.IDEQ(accountID)).Only(ctx)
}

func (r *BalanceFlowRepo) GetRawEntity(ctx context.Context, id uint32) (*ent.BalanceFlow, error) {
	return r.entClient.Client().BalanceFlow.Query().Where(balanceflow.IDEQ(id)).Only(ctx)
}

// CategoryRelation helpers
type CategoryRelationItem struct {
	CategoryID      uint32
	Amount          float64
	ConvertedAmount *float64
}

type TagRelationItem struct {
	TagID           uint32
	Amount          float64
	ConvertedAmount *float64
}

func (r *BalanceFlowRepo) CreateCategoryRelations(ctx context.Context, flowID uint32, categories []*CategoryRelationItem) error {
	bulk := make([]*ent.CategoryRelationCreate, 0, len(categories))
	for _, c := range categories {
		bulk = append(bulk, r.entClient.Client().CategoryRelation.Create().
			SetBalanceFlowID(flowID).
			SetCategoryID(c.CategoryID).
			SetAmount(c.Amount).
			SetNillableConvertedAmount(c.ConvertedAmount))
	}
	_, err := r.entClient.Client().CategoryRelation.CreateBulk(bulk...).Save(ctx)
	return err
}

func (r *BalanceFlowRepo) DeleteCategoryRelationsByFlow(ctx context.Context, flowID uint32) error {
	_, err := r.entClient.Client().CategoryRelation.Delete().
		Where(func(s *sql.Selector) { s.Where(sql.EQ("balance_flow_id", flowID)) }).Exec(ctx)
	return err
}

func (r *BalanceFlowRepo) CreateTagRelations(ctx context.Context, flowID uint32, tags []*TagRelationItem) error {
	bulk := make([]*ent.TagRelationCreate, 0, len(tags))
	for _, t := range tags {
		bulk = append(bulk, r.entClient.Client().TagRelation.Create().
			SetBalanceFlowID(flowID).
			SetTagID(t.TagID).
			SetAmount(t.Amount).
			SetNillableConvertedAmount(t.ConvertedAmount))
	}
	_, err := r.entClient.Client().TagRelation.CreateBulk(bulk...).Save(ctx)
	return err
}

func (r *BalanceFlowRepo) DeleteTagRelationsByFlow(ctx context.Context, flowID uint32) error {
	_, err := r.entClient.Client().TagRelation.Delete().
		Where(func(s *sql.Selector) { s.Where(sql.EQ("balance_flow_id", flowID)) }).Exec(ctx)
	return err
}

// === Public query methods for ReportService ===

// QueryFlowsByType returns confirmed+included flows of a given type in a book.
func (r *BalanceFlowRepo) QueryFlowsByType(ctx context.Context, bookID uint32, flowType balanceflow.Type) ([]*ent.BalanceFlow, error) {
	return r.entClient.Client().BalanceFlow.Query().
		Where(
			balanceflow.BookIDEQ(bookID),
			balanceflow.TypeEQ(flowType),
			balanceflow.ConfirmEQ(true),
			balanceflow.IncludeEQ(true),
		).
		All(ctx)
}

// QueryFlowsByBook returns all flows in a book ordered by create_time ascending.
func (r *BalanceFlowRepo) QueryFlowsByBook(ctx context.Context, bookID uint32) ([]*ent.BalanceFlow, error) {
	return r.entClient.Client().BalanceFlow.Query().
		Where(balanceflow.BookIDEQ(bookID)).
		Order(ent.Asc(balanceflow.FieldCreateTime)).
		All(ctx)
}

// QueryCategoryRelationsByFlowIDs returns category relations for the given flow IDs.
func (r *BalanceFlowRepo) QueryCategoryRelationsByFlowIDs(ctx context.Context, flowIDs []uint32) ([]*ent.CategoryRelation, error) {
	return r.entClient.Client().CategoryRelation.Query().
		Where(categoryrelation.BalanceFlowIDIn(flowIDs...)).
		All(ctx)
}

// QueryTagRelationsByFlowIDs returns tag relations for the given flow IDs.
func (r *BalanceFlowRepo) QueryTagRelationsByFlowIDs(ctx context.Context, flowIDs []uint32) ([]*ent.TagRelation, error) {
	return r.entClient.Client().TagRelation.Query().
		Where(tagrelation.BalanceFlowIDIn(flowIDs...)).
		All(ctx)
}

// QueryAllCategories returns all categories (for name lookup).
func (r *BalanceFlowRepo) QueryAllCategories(ctx context.Context) ([]*ent.Category, error) {
	return r.entClient.Client().Category.Query().All(ctx)
}

// QueryAllTags returns all tags (for name lookup).
func (r *BalanceFlowRepo) QueryAllTags(ctx context.Context) ([]*ent.Tag, error) {
	return r.entClient.Client().Tag.Query().All(ctx)
}

// QueryAllPayees returns all payees (for name lookup).
func (r *BalanceFlowRepo) QueryAllPayees(ctx context.Context) ([]*ent.Payee, error) {
	return r.entClient.Client().Payee.Query().All(ctx)
}

// QueryEnabledAccounts returns enabled+included accounts (for balance report).
func (r *BalanceFlowRepo) QueryEnabledAccounts(ctx context.Context) ([]*ent.Account, error) {
	return r.entClient.Client().Account.Query().
		Where(account.EnableEQ(true), account.IncludeEQ(true)).
		All(ctx)
}
