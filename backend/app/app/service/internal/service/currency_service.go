package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	appV1 "go-wind-cms/api/gen/go/app/service/v1"
	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type CurrencyService struct {
	appV1.CurrencyServiceHTTPServer

	client ledgerV1.CurrencyServiceClient
	log    *log.Helper
}

func NewCurrencyService(ctx *bootstrap.Context, client ledgerV1.CurrencyServiceClient) *CurrencyService {
	return &CurrencyService{
		log:    ctx.NewLoggerHelper("currency/service/app-service"),
		client: client,
	}
}

func (s *CurrencyService) ListAll(ctx context.Context, req *ledgerV1.ListAllCurrencyRequest) (*ledgerV1.ListCurrencyResponse, error) {
	return s.client.ListAll(ctx, req)
}

func (s *CurrencyService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListCurrencyResponse, error) {
	return s.client.List(ctx, req)
}

func (s *CurrencyService) Refresh(ctx context.Context, req *ledgerV1.RefreshCurrencyRequest) (*ledgerV1.ListCurrencyResponse, error) {
	return s.client.Refresh(ctx, req)
}

func (s *CurrencyService) Convert(ctx context.Context, req *ledgerV1.ConvertCurrencyRequest) (*ledgerV1.ConvertCurrencyResponse, error) {
	return s.client.Convert(ctx, req)
}

func (s *CurrencyService) ChangeRate(ctx context.Context, req *ledgerV1.ChangeRateRequest) (*ledgerV1.Currency, error) {
	return s.client.ChangeRate(ctx, req)
}
