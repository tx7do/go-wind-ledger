package data

import (
	"context"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/copierutil"
	"github.com/tx7do/go-utils/mapper"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	"go-wind-cms/app/core/service/internal/data/ent"
	"go-wind-cms/app/core/service/internal/data/ent/balanceflow"
	"go-wind-cms/app/core/service/internal/data/ent/budget"
	"go-wind-cms/app/core/service/internal/data/ent/categoryrelation"
	"go-wind-cms/app/core/service/internal/data/ent/predicate"

	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

// BudgetRepo 预算仓库
type BudgetRepo struct {
	entClient  *entCrud.EntClient[*ent.Client]
	log        *log.Helper
	mapper     *mapper.CopierMapper[ledgerV1.Budget, ent.Budget]
	repository *entCrud.Repository[
		ent.BudgetQuery, ent.BudgetSelect,
		ent.BudgetCreate, ent.BudgetCreateBulk,
		ent.BudgetUpdate, ent.BudgetUpdateOne,
		ent.BudgetDelete,
		predicate.Budget,
		ledgerV1.Budget, ent.Budget,
	]
}

// NewBudgetRepo 创建预算仓库
func NewBudgetRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *BudgetRepo {
	repo := &BudgetRepo{
		log:       ctx.NewLoggerHelper("budget/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[ledgerV1.Budget, ent.Budget](),
	}
	repo.init()
	return repo
}

func (r *BudgetRepo) init() {
	r.repository = entCrud.NewRepository[
		ent.BudgetQuery, ent.BudgetSelect,
		ent.BudgetCreate, ent.BudgetCreateBulk,
		ent.BudgetUpdate, ent.BudgetUpdateOne,
		ent.BudgetDelete,
		predicate.Budget,
		ledgerV1.Budget, ent.Budget,
	](r.mapper)
	r.mapper.AppendConverters(copierutil.NewTimeStringConverterPair())
	r.mapper.AppendConverters(copierutil.NewTimeTimestamppbConverterPair())
}

// List 分页查询预算
func (r *BudgetRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListBudgetResponse, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Budget.Query()
	ret, err := r.repository.ListWithPaging(ctx, builder, builder.Clone(), req)
	if err != nil {
		return nil, err
	}
	if ret == nil {
		return &ledgerV1.ListBudgetResponse{Total: 0}, nil
	}
	return &ledgerV1.ListBudgetResponse{Total: ret.Total, Items: ret.Items}, nil
}

// ListAll 按 book_id 查询全部预算
func (r *BudgetRepo) ListAll(ctx context.Context, bookID uint32) (*ledgerV1.ListBudgetResponse, error) {
	entities, err := r.entClient.Client().Budget.Query().
		Where(budget.BookIDEQ(bookID)).
		All(ctx)
	if err != nil {
		r.log.Errorf("list budget by book failed: %s", err.Error())
		return nil, ledgerV1.ErrorInternalServerError("list budget failed")
	}
	items := make([]*ledgerV1.Budget, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &ledgerV1.ListBudgetResponse{Items: items, Total: uint64(len(items))}, nil
}

// Get 按 id 查询预算
func (r *BudgetRepo) Get(ctx context.Context, id uint32) (*ledgerV1.Budget, error) {
	entity, err := r.entClient.Client().Budget.Query().Where(budget.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("budget not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get budget failed")
	}
	return r.mapper.ToDTO(entity), nil
}

// Create 创建预算
func (r *BudgetRepo) Create(ctx context.Context, data *ledgerV1.Budget) (*ledgerV1.Budget, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Budget.Create().
		SetNillableTenantID(data.TenantId).
		SetNillableBookID(data.BookId).
		SetNillableName(data.Name).
		SetNillableAmount(strPtrToFloatPtr(data.Amount)).
		SetNillableUsedAmount(strPtrToFloatPtr(data.UsedAmount)).
		SetNillableCategoryID(data.CategoryId).
		SetNillableAccountID(data.AccountId).
		SetNillableStartDate(data.StartDate).
		SetNillableEndDate(data.EndDate).
		SetNillableEnable(data.Enable).
		SetNillableNotify(data.Notify).
		SetNillableNotes(data.Notes).
		SetNillableCreatedBy(data.CreatedBy).
		SetCreatedAt(time.Now())
	if data.Period != nil {
		builder = builder.SetPeriod(budget.Period(data.Period.String()))
	}
	saved, err := builder.Save(ctx)
	if err != nil {
		r.log.Errorf("create budget failed: %s", err.Error())
		return nil, ledgerV1.ErrorInternalServerError("create budget failed")
	}
	return r.mapper.ToDTO(saved), nil
}

// Update 更新预算
func (r *BudgetRepo) Update(ctx context.Context, id uint32, data *ledgerV1.Budget, mask *fieldmaskpb.FieldMask) (*ledgerV1.Budget, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	exist, _ := r.entClient.Client().Budget.Query().Where(budget.IDEQ(id)).Exist(ctx)
	if !exist {
		return nil, ledgerV1.ErrorNotFound("budget not found")
	}
	builder := r.entClient.Client().Budget.UpdateOneID(id).SetUpdatedAt(time.Now())
	applyAll := mask == nil || len(mask.Paths) == 0
	if applyAll {
		builder = builder.
			SetNillableName(data.Name).
			SetNillableAmount(strPtrToFloatPtr(data.Amount)).
			SetNillableUsedAmount(strPtrToFloatPtr(data.UsedAmount)).
			SetNillableCategoryID(data.CategoryId).
			SetNillableAccountID(data.AccountId).
			SetNillableStartDate(data.StartDate).
			SetNillableEndDate(data.EndDate).
			SetNillableEnable(data.Enable).
			SetNillableNotify(data.Notify).
			SetNillableNotes(data.Notes).
			SetNillableUpdatedBy(data.UpdatedBy)
		if data.Period != nil {
			builder = builder.SetPeriod(budget.Period(data.Period.String()))
		}
	} else {
		for _, path := range mask.Paths {
			switch path {
			case "name":
				builder = builder.SetNillableName(data.Name)
			case "period":
				if data.Period != nil {
					builder = builder.SetPeriod(budget.Period(data.Period.String()))
				}
			case "amount":
				builder = builder.SetNillableAmount(strPtrToFloatPtr(data.Amount))
			case "used_amount":
				builder = builder.SetNillableUsedAmount(strPtrToFloatPtr(data.UsedAmount))
			case "category_id":
				builder = builder.SetNillableCategoryID(data.CategoryId)
			case "account_id":
				builder = builder.SetNillableAccountID(data.AccountId)
			case "start_date":
				builder = builder.SetNillableStartDate(data.StartDate)
			case "end_date":
				builder = builder.SetNillableEndDate(data.EndDate)
			case "enable":
				builder = builder.SetNillableEnable(data.Enable)
			case "notify":
				builder = builder.SetNillableNotify(data.Notify)
			case "notes":
				builder = builder.SetNillableNotes(data.Notes)
			case "updated_by":
				builder = builder.SetNillableUpdatedBy(data.UpdatedBy)
			}
		}
	}
	updated, err := builder.Save(ctx)
	if err != nil {
		r.log.Errorf("update budget failed: %s", err.Error())
		return nil, ledgerV1.ErrorInternalServerError("update budget failed")
	}
	return r.mapper.ToDTO(updated), nil
}

// Delete 删除预算
func (r *BudgetRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().Budget.DeleteOneID(id).Exec(ctx)
}

// CalculateUsedAmount 汇总 balance_flow 的 converted_amount 计算预算已用金额。
// 过滤条件：book_id、可选 category_id、可选 account_id、可选 start_date/end_date（按 create_time）。
// 仅统计已确认(confirm=true)且纳入统计(include=true)的流水。
func (r *BudgetRepo) CalculateUsedAmount(ctx context.Context, b *ledgerV1.Budget) (float64, error) {
	if b == nil || b.GetBookId() == 0 {
		return 0, nil
	}
	q := r.entClient.Client().BalanceFlow.Query().
		Where(
			balanceflow.BookIDEQ(b.GetBookId()),
			balanceflow.ConfirmEQ(true),
			balanceflow.IncludeEQ(true),
		)

	// 按账户过滤
	if b.GetAccountId() != 0 {
		q = q.Where(balanceflow.AccountIDEQ(b.GetAccountId()))
	}

	// 按周期（create_time，epoch 毫秒）过滤
	if b.GetStartDate() != 0 {
		q = q.Where(balanceflow.CreateTimeGTE(b.GetStartDate()))
	}
	if b.GetEndDate() != 0 {
		q = q.Where(balanceflow.CreateTimeLTE(b.GetEndDate()))
	}

	// 按分类过滤：balance_flow 没有直接的 category_id 字段，
	// 需通过 category_relation 表查得关联的 balance_flow_id 列表后做 IN 过滤。
	if b.GetCategoryId() != 0 {
		relations, err := r.entClient.Client().CategoryRelation.Query().
			Where(categoryrelation.CategoryIDEQ(b.GetCategoryId())).
			All(ctx)
		if err != nil {
			r.log.Errorf("query category relations failed: %s", err.Error())
			return 0, ledgerV1.ErrorInternalServerError("calculate used amount failed")
		}
		flowIDs := make([]uint32, 0, len(relations))
		for _, rel := range relations {
			if rel.BalanceFlowID != nil && *rel.BalanceFlowID != 0 {
				flowIDs = append(flowIDs, *rel.BalanceFlowID)
			}
		}
		if len(flowIDs) == 0 {
			return 0, nil
		}
		q = q.Where(balanceflow.IDIn(flowIDs...))
	}

	flows, err := q.All(ctx)
	if err != nil {
		r.log.Errorf("query balance flows for budget failed: %s", err.Error())
		return 0, ledgerV1.ErrorInternalServerError("calculate used amount failed")
	}

	var total float64
	for _, f := range flows {
		if f.ConvertedAmount != nil {
			total += *f.ConvertedAmount
		}
	}
	return total, nil
}
