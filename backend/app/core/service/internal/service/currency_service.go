package service

import (
	"context"
	"encoding/json"
	"sync"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type CurrencyService struct {
	ledgerV1.UnimplementedCurrencyServiceServer
	log       *log.Helper
	currencies []*ledgerV1.Currency
	mu         sync.RWMutex
}

func NewCurrencyService(ctx *bootstrap.Context) *CurrencyService {
	svc := &CurrencyService{
		log: ctx.NewLoggerHelper("currency/service/core-service"),
	}
	svc.loadSeed()
	return svc
}

func (s *CurrencyService) loadSeed() {
	// Seed data from common currency codes with approximate USD rates
	s.currencies = []*ledgerV1.Currency{
		{Id: uint32Ptr(1), Code: strPtr("CNY"), Name: strPtr("人民币"), Rate: strPtr("7.2")},
		{Id: uint32Ptr(2), Code: strPtr("USD"), Name: strPtr("美元"), Rate: strPtr("1.0")},
		{Id: uint32Ptr(3), Code: strPtr("EUR"), Name: strPtr("欧元"), Rate: strPtr("0.92")},
		{Id: uint32Ptr(4), Code: strPtr("JPY"), Name: strPtr("日元"), Rate: strPtr("148.0")},
		{Id: uint32Ptr(5), Code: strPtr("GBP"), Name: strPtr("英镑"), Rate: strPtr("0.79")},
		{Id: uint32Ptr(6), Code: strPtr("HKD"), Name: strPtr("港币"), Rate: strPtr("7.8")},
		{Id: uint32Ptr(7), Code: strPtr("KRW"), Name: strPtr("韩元"), Rate: strPtr("1340.0")},
		{Id: uint32Ptr(8), Code: strPtr("AUD"), Name: strPtr("澳元"), Rate: strPtr("1.52")},
		{Id: uint32Ptr(9), Code: strPtr("CAD"), Name: strPtr("加元"), Rate: strPtr("1.36")},
		{Id: uint32Ptr(10), Code: strPtr("CHF"), Name: strPtr("瑞郎"), Rate: strPtr("0.88")},
	}
}

func (s *CurrencyService) ListAll(ctx context.Context, req *ledgerV1.ListAllCurrencyRequest) (*ledgerV1.ListCurrencyResponse, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return &ledgerV1.ListCurrencyResponse{Items: s.currencies, Total: uint64(len(s.currencies))}, nil
}

func (s *CurrencyService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListCurrencyResponse, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	// Simple in-memory paging
	offset := int((req.GetPage() - 1) * req.GetPageSize())
	limit := int(req.GetPageSize())
	list := s.currencies
	if offset < len(list) {
		end := offset + limit
		if end > len(list) {
			end = len(list)
		}
		list = list[offset:end]
	} else {
		list = nil
	}
	return &ledgerV1.ListCurrencyResponse{Items: list, Total: uint64(len(s.currencies))}, nil
}

func (s *CurrencyService) Refresh(ctx context.Context, req *ledgerV1.RefreshCurrencyRequest) (*ledgerV1.ListCurrencyResponse, error) {
	// TODO: In production, call external API like https://api.exchangerate-api.com/v4/latest/USD
	// For now, return the current currency list (seed rates remain unchanged).
	s.log.Infof("currency refresh requested - using seed rates (external API not yet configured)")
	return s.ListAll(ctx, &ledgerV1.ListAllCurrencyRequest{})
}

func (s *CurrencyService) Convert(ctx context.Context, req *ledgerV1.ConvertCurrencyRequest) (*ledgerV1.ConvertCurrencyResponse, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	fromRate := s.findRate(req.GetFrom())
	toRate := s.findRate(req.GetTo())
	if fromRate == 0 || toRate == 0 {
		return nil, ledgerV1.ErrorBadRequest("unsupported currency")
	}

	amount := parseFloat(req.GetAmount())
	rate := toRate / fromRate
	converted := amount * rate

	return &ledgerV1.ConvertCurrencyResponse{
		Amount: formatFloat(converted),
		Rate:   formatFloat(rate),
	}, nil
}

// ChangeRate 手动修改指定币种的汇率（内存实现，直接修改缓存）。
func (s *CurrencyService) ChangeRate(ctx context.Context, req *ledgerV1.ChangeRateRequest) (*ledgerV1.Currency, error) {
	if req == nil || req.GetId() == 0 {
		return nil, ledgerV1.ErrorBadRequest("invalid currency id")
	}
	if req.GetRate() == "" {
		return nil, ledgerV1.ErrorBadRequest("rate is required")
	}
	// 校验 rate 必须为合法数值
	if parseFloat(req.GetRate()) == 0 {
		return nil, ledgerV1.ErrorBadRequest("invalid rate value")
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	for _, c := range s.currencies {
		if c.GetId() == req.GetId() {
			rate := req.GetRate()
			c.Rate = &rate
			s.log.Infof("currency rate changed id=%d code=%s", c.GetId(), c.GetCode())
			return c, nil
		}
	}
	return nil, ledgerV1.ErrorNotFound("currency not found")
}

func (s *CurrencyService) findRate(code string) float64 {
	for _, c := range s.currencies {
		if c.GetCode() == code {
			return parseFloat(c.GetRate())
		}
	}
	return 0
}

func parseFloat(s string) float64 {
	var f float64
	if err := json.Unmarshal([]byte(s), &f); err != nil {
		f = 0
	}
	return f
}

func formatFloat(f float64) string {
	b, _ := json.Marshal(f)
	return string(b)
}

func strPtr(s string) *string { return &s }

func uint32Ptr(v uint32) *uint32 { return &v }
