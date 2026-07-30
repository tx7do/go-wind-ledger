package service

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
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

// exchangeRateAPIResponse is the JSON structure returned by the free
// exchange rate API (https://api.exchangerate-api.com/v4/latest/USD).
type exchangeRateAPIResponse struct {
	Rates map[string]float64 `json:"rates"`
}

// exchangeRateAPIURL is the endpoint for fetching live exchange rates.
// Free tier: no API key required, updates daily.
const exchangeRateAPIURL = "https://api.exchangerate-api.com/v4/latest/USD"

// httpClient is a shared client with a reasonable timeout for external API calls.
var httpClient = &http.Client{Timeout: 10 * time.Second}

func (s *CurrencyService) Refresh(ctx context.Context, req *ledgerV1.RefreshCurrencyRequest) (*ledgerV1.ListCurrencyResponse, error) {
	liveRates, err := fetchLiveRates(ctx)
	if err != nil {
		s.log.Warnf("failed to fetch live exchange rates, keeping seed rates: %v", err)
		return s.ListAll(ctx, &ledgerV1.ListAllCurrencyRequest{})
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	updated := 0
	for _, c := range s.currencies {
		code := c.GetCode()
		if rate, ok := liveRates[code]; ok && rate > 0 {
			s := formatFloat(rate)
			c.Rate = &s
			updated++
		}
	}

	s.log.Infof("currency rates refreshed: %d/%d updated from API", updated, len(s.currencies))
	return &ledgerV1.ListCurrencyResponse{Items: s.currencies, Total: uint64(len(s.currencies))}, nil
}

// fetchLiveRates calls the exchange rate API and returns a map of currency code → rate to USD.
func fetchLiveRates(ctx context.Context) (map[string]float64, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, exchangeRateAPIURL, nil)
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("http get: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 1024))
		return nil, fmt.Errorf("unexpected status %d: %s", resp.StatusCode, string(body))
	}

	var result exchangeRateAPIResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decode response: %w", err)
	}

	if result.Rates == nil {
		return nil, fmt.Errorf("empty rates in API response")
	}

	return result.Rates, nil
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
