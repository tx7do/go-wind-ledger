package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/go-utils/trans"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	appV1 "go-wind-cms/api/gen/go/app/service/v1"
	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"

	"go-wind-cms/pkg/middleware/auth"
)

type BudgetService struct {
	appV1.BudgetServiceHTTPServer

	client ledgerV1.BudgetServiceClient
	log    *log.Helper
}

func NewBudgetService(ctx *bootstrap.Context, client ledgerV1.BudgetServiceClient) *BudgetService {
	return &BudgetService{
		log:    ctx.NewLoggerHelper("budget/service/app-service"),
		client: client,
	}
}

func (s *BudgetService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListBudgetResponse, error) {
	return s.client.List(ctx, req)
}

func (s *BudgetService) ListAll(ctx context.Context, req *ledgerV1.ListAllBudgetRequest) (*ledgerV1.ListBudgetResponse, error) {
	return s.client.ListAll(ctx, req)
}

func (s *BudgetService) Get(ctx context.Context, req *ledgerV1.GetBudgetRequest) (*ledgerV1.Budget, error) {
	return s.client.Get(ctx, req)
}

func (s *BudgetService) Create(ctx context.Context, req *ledgerV1.CreateBudgetRequest) (*ledgerV1.Budget, error) {
	if req.Data == nil {
		return nil, appV1.ErrorBadRequest("invalid parameter")
	}
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}
	req.Data.CreatedBy = trans.Ptr(operator.UserId)
	return s.client.Create(ctx, req)
}

func (s *BudgetService) Update(ctx context.Context, req *ledgerV1.UpdateBudgetRequest) (*ledgerV1.Budget, error) {
	if req.Data == nil {
		return nil, appV1.ErrorBadRequest("invalid parameter")
	}
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}
	req.Data.UpdatedBy = trans.Ptr(operator.GetUserId())
	if req.UpdateMask != nil {
		req.UpdateMask.Paths = append(req.UpdateMask.Paths, "updated_by")
	}
	return s.client.Update(ctx, req)
}

func (s *BudgetService) Delete(ctx context.Context, req *ledgerV1.DeleteBudgetRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}

func (s *BudgetService) GetProgress(ctx context.Context, req *ledgerV1.GetBudgetProgressRequest) (*ledgerV1.BudgetProgress, error) {
	return s.client.GetProgress(ctx, req)
}
