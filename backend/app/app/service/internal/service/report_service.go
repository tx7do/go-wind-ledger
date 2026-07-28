package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	appV1 "go-wind-cms/api/gen/go/app/service/v1"
	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type ReportService struct {
	appV1.ReportServiceHTTPServer

	client ledgerV1.ReportServiceClient
	log    *log.Helper
}

func NewReportService(ctx *bootstrap.Context, client ledgerV1.ReportServiceClient) *ReportService {
	return &ReportService{
		log:    ctx.NewLoggerHelper("report/service/app-service"),
		client: client,
	}
}

func (s *ReportService) ExpenseCategory(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.client.ExpenseCategory(ctx, req)
}

func (s *ReportService) IncomeCategory(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.client.IncomeCategory(ctx, req)
}

func (s *ReportService) ExpenseTag(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.client.ExpenseTag(ctx, req)
}

func (s *ReportService) IncomeTag(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.client.IncomeTag(ctx, req)
}

func (s *ReportService) ExpensePayee(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.client.ExpensePayee(ctx, req)
}

func (s *ReportService) IncomePayee(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.client.IncomePayee(ctx, req)
}

func (s *ReportService) Balance(ctx context.Context, req *ledgerV1.BalanceReportRequest) (*ledgerV1.BalanceReportResponse, error) {
	return s.client.Balance(ctx, req)
}
