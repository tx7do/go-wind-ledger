package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	appV1 "go-wind-ledger/api/gen/go/app/service/v1"
	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

type BalanceFlowService struct {
	appV1.BalanceFlowServiceHTTPServer

	client ledgerV1.BalanceFlowServiceClient
	log    *log.Helper
}

func NewBalanceFlowService(ctx *bootstrap.Context, client ledgerV1.BalanceFlowServiceClient) *BalanceFlowService {
	return &BalanceFlowService{
		log:    ctx.NewLoggerHelper("balance-flow/service/app-service"),
		client: client,
	}
}

func (s *BalanceFlowService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListBalanceFlowResponse, error) {
	return s.client.List(ctx, req)
}

func (s *BalanceFlowService) Get(ctx context.Context, req *ledgerV1.GetBalanceFlowRequest) (*ledgerV1.BalanceFlow, error) {
	return s.client.Get(ctx, req)
}

func (s *BalanceFlowService) Create(ctx context.Context, req *ledgerV1.CreateBalanceFlowRequest) (*ledgerV1.BalanceFlow, error) {
	return s.client.Create(ctx, req)
}

func (s *BalanceFlowService) Update(ctx context.Context, req *ledgerV1.UpdateBalanceFlowRequest) (*ledgerV1.BalanceFlow, error) {
	return s.client.Update(ctx, req)
}

func (s *BalanceFlowService) Delete(ctx context.Context, req *ledgerV1.DeleteBalanceFlowRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}

func (s *BalanceFlowService) Confirm(ctx context.Context, req *ledgerV1.ConfirmBalanceFlowRequest) (*ledgerV1.BalanceFlow, error) {
	return s.client.Confirm(ctx, req)
}

func (s *BalanceFlowService) Statistics(ctx context.Context, req *ledgerV1.StatisticsRequest) (*ledgerV1.StatisticsResponse, error) {
	return s.client.Statistics(ctx, req)
}
