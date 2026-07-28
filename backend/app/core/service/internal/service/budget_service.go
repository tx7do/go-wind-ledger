package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/go-utils/trans"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	"go-wind-cms/app/core/service/internal/data"

	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

// BudgetService 预算服务
type BudgetService struct {
	ledgerV1.UnimplementedBudgetServiceServer

	log *log.Helper

	budgetRepo *data.BudgetRepo
	flowRepo   *data.BalanceFlowRepo
}

// NewBudgetService 创建预算服务。
func NewBudgetService(
	ctx *bootstrap.Context,
	budgetRepo *data.BudgetRepo,
	flowRepo *data.BalanceFlowRepo,
) *BudgetService {
	return &BudgetService{
		log:        ctx.NewLoggerHelper("budget/service/core-service"),
		budgetRepo: budgetRepo,
		flowRepo:   flowRepo,
	}
}

// List 分页查询预算
func (s *BudgetService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListBudgetResponse, error) {
	return s.budgetRepo.List(ctx, req)
}

// ListAll 获取所有预算（不分页，按 book_id）
func (s *BudgetService) ListAll(ctx context.Context, req *ledgerV1.ListAllBudgetRequest) (*ledgerV1.ListBudgetResponse, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	return s.budgetRepo.ListAll(ctx, req.GetBookId())
}

// Get 获取预算数据
func (s *BudgetService) Get(ctx context.Context, req *ledgerV1.GetBudgetRequest) (*ledgerV1.Budget, error) {
	if req == nil || req.GetId() == 0 {
		return nil, ledgerV1.ErrorBadRequest("invalid id")
	}
	return s.budgetRepo.Get(ctx, req.GetId())
}

// Create 创建预算
func (s *BudgetService) Create(ctx context.Context, req *ledgerV1.CreateBudgetRequest) (*ledgerV1.Budget, error) {
	if req == nil || req.GetData() == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	return s.budgetRepo.Create(ctx, req.GetData())
}

// Update 更新预算
func (s *BudgetService) Update(ctx context.Context, req *ledgerV1.UpdateBudgetRequest) (*ledgerV1.Budget, error) {
	if req == nil || req.GetData() == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	return s.budgetRepo.Update(ctx, req.GetId(), req.GetData(), req.GetUpdateMask())
}

// Delete 删除预算
func (s *BudgetService) Delete(ctx context.Context, req *ledgerV1.DeleteBudgetRequest) (*emptypb.Empty, error) {
	if req == nil || req.GetId() == 0 {
		return nil, ledgerV1.ErrorBadRequest("invalid id")
	}
	if err := s.budgetRepo.Delete(ctx, req.GetId()); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

// GetProgress 获取预算进度（已用金额/预算金额）。
// 调用 repo.CalculateUsedAmount 计算 used_amount，并返回 remaining/usage_percent/exceeded。
func (s *BudgetService) GetProgress(ctx context.Context, req *ledgerV1.GetBudgetProgressRequest) (*ledgerV1.BudgetProgress, error) {
	if req == nil || req.GetId() == 0 {
		return nil, ledgerV1.ErrorBadRequest("invalid id")
	}

	b, err := s.budgetRepo.Get(ctx, req.GetId())
	if err != nil {
		return nil, err
	}

	used, err := s.budgetRepo.CalculateUsedAmount(ctx, b)
	if err != nil {
		return nil, err
	}

	amount := data.StrToFloat(b.GetAmount())
	remaining := amount - used
	var usagePercent float64
	if amount > 0 {
		usagePercent = (used / amount) * 100
	}
	exceeded := used > amount && amount > 0

	progress := &ledgerV1.BudgetProgress{
		BudgetId:    trans.Ptr(b.GetId()),
		BudgetName:  b.Name,
		Amount:      b.Amount,
		UsedAmount:  trans.Ptr(data.FloatToStr(used)),
		Remaining:   trans.Ptr(data.FloatToStr(remaining)),
		UsagePercent: trans.Ptr(data.FloatToStr(usagePercent)),
		Exceeded:    trans.Ptr(exceeded),
		PeriodStart: b.StartDate,
		PeriodEnd:   b.EndDate,
	}
	return progress, nil
}
