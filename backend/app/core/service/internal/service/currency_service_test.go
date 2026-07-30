package service

import (
	"context"
	"testing"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/stretchr/testify/assert"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

func newTestCurrencyService() *CurrencyService {
	svc := &CurrencyService{
		log: log.NewHelper(log.DefaultLogger),
	}
	svc.loadSeed()
	return svc
}

// ─── ListAll ──────────────────────────────────────────

func TestCurrencyService_ListAll(t *testing.T) {
	svc := newTestCurrencyService()
	resp, err := svc.ListAll(context.Background(), &ledgerV1.ListAllCurrencyRequest{})
	assert.NoError(t, err)
	assert.NotNil(t, resp)
	assert.Len(t, resp.Items, 10)
	assert.Equal(t, uint64(10), resp.Total)
}

// ─── List (pagination) ────────────────────────────────

func TestCurrencyService_List_FirstPage(t *testing.T) {
	svc := newTestCurrencyService()
	resp, err := svc.List(context.Background(), &paginationV1.PagingRequest{
		Page:     uint32Ptr(1),
		PageSize: uint32Ptr(5),
	})
	assert.NoError(t, err)
	assert.Len(t, resp.Items, 5)
	assert.Equal(t, uint64(10), resp.Total)
}

func TestCurrencyService_List_SecondPage(t *testing.T) {
	svc := newTestCurrencyService()
	resp, err := svc.List(context.Background(), &paginationV1.PagingRequest{
		Page:     uint32Ptr(2),
		PageSize: uint32Ptr(5),
	})
	assert.NoError(t, err)
	assert.Len(t, resp.Items, 5)
}

func TestCurrencyService_List_OutOfRange(t *testing.T) {
	svc := newTestCurrencyService()
	resp, err := svc.List(context.Background(), &paginationV1.PagingRequest{
		Page:     uint32Ptr(10),
		PageSize: uint32Ptr(20),
	})
	assert.NoError(t, err)
	assert.Empty(t, resp.Items)
	assert.Equal(t, uint64(10), resp.Total)
}

func TestCurrencyService_List_PageSizeLargerThanTotal(t *testing.T) {
	svc := newTestCurrencyService()
	resp, err := svc.List(context.Background(), &paginationV1.PagingRequest{
		Page:     uint32Ptr(1),
		PageSize: uint32Ptr(100),
	})
	assert.NoError(t, err)
	assert.Len(t, resp.Items, 10)
}

// ─── Convert ──────────────────────────────────────────

func TestCurrencyService_Convert_USDToCNY(t *testing.T) {
	svc := newTestCurrencyService()
	resp, err := svc.Convert(context.Background(), &ledgerV1.ConvertCurrencyRequest{
		Amount: "100",
		From:   "USD",
		To:     "CNY",
	})
	assert.NoError(t, err)
	// 100 USD * 7.2 = 720 CNY
	amount := parseFloat(resp.GetAmount())
	assert.InDelta(t, 720.0, amount, 0.01)
}

func TestCurrencyService_Convert_CNYToUSD(t *testing.T) {
	svc := newTestCurrencyService()
	resp, err := svc.Convert(context.Background(), &ledgerV1.ConvertCurrencyRequest{
		Amount: "720",
		From:   "CNY",
		To:     "USD",
	})
	assert.NoError(t, err)
	amount := parseFloat(resp.GetAmount())
	assert.InDelta(t, 100.0, amount, 0.01)
}

func TestCurrencyService_Convert_SameCurrency(t *testing.T) {
	svc := newTestCurrencyService()
	resp, err := svc.Convert(context.Background(), &ledgerV1.ConvertCurrencyRequest{
		Amount: "100",
		From:   "USD",
		To:     "USD",
	})
	assert.NoError(t, err)
	amount := parseFloat(resp.GetAmount())
	assert.InDelta(t, 100.0, amount, 0.01)
}

func TestCurrencyService_Convert_UnsupportedCurrency(t *testing.T) {
	svc := newTestCurrencyService()
	_, err := svc.Convert(context.Background(), &ledgerV1.ConvertCurrencyRequest{
		Amount: "100",
		From:   "USD",
		To:     "XXX",
	})
	assert.Error(t, err)
}

func TestCurrencyService_Convert_CrossCurrency(t *testing.T) {
	svc := newTestCurrencyService()
	// EUR → JPY: 100 EUR * (148/0.92) ≈ 16086.96
	resp, err := svc.Convert(context.Background(), &ledgerV1.ConvertCurrencyRequest{
		Amount: "100",
		From:   "EUR",
		To:     "JPY",
	})
	assert.NoError(t, err)
	amount := parseFloat(resp.GetAmount())
	assert.InDelta(t, 16086.95, amount, 1.0)
}

// ─── ChangeRate ───────────────────────────────────────

func TestCurrencyService_ChangeRate_Success(t *testing.T) {
	svc := newTestCurrencyService()
	updated, err := svc.ChangeRate(context.Background(), &ledgerV1.ChangeRateRequest{
		Id:   1,
		Rate: "7.5",
	})
	assert.NoError(t, err)
	assert.Equal(t, "CNY", updated.GetCode())
	assert.Equal(t, "7.5", updated.GetRate())

	// Verify Convert uses the new rate
	resp, err := svc.Convert(context.Background(), &ledgerV1.ConvertCurrencyRequest{
		Amount: "100",
		From:   "USD",
		To:     "CNY",
	})
	assert.NoError(t, err)
	amount := parseFloat(resp.GetAmount())
	assert.InDelta(t, 750.0, amount, 0.01)
}

func TestCurrencyService_ChangeRate_NotFound(t *testing.T) {
	svc := newTestCurrencyService()
	_, err := svc.ChangeRate(context.Background(), &ledgerV1.ChangeRateRequest{
		Id:   999,
		Rate: "1.0",
	})
	assert.Error(t, err)
}

func TestCurrencyService_ChangeRate_ZeroId(t *testing.T) {
	svc := newTestCurrencyService()
	_, err := svc.ChangeRate(context.Background(), &ledgerV1.ChangeRateRequest{
		Id:   0,
		Rate: "1.0",
	})
	assert.Error(t, err)
}

func TestCurrencyService_ChangeRate_EmptyRate(t *testing.T) {
	svc := newTestCurrencyService()
	_, err := svc.ChangeRate(context.Background(), &ledgerV1.ChangeRateRequest{
		Id:   1,
		Rate: "",
	})
	assert.Error(t, err)
}

func TestCurrencyService_ChangeRate_InvalidRateValue(t *testing.T) {
	svc := newTestCurrencyService()
	_, err := svc.ChangeRate(context.Background(), &ledgerV1.ChangeRateRequest{
		Id:   1,
		Rate: "not-a-number",
	})
	assert.Error(t, err)
}

// ─── Thread safety ────────────────────────────────────

func TestCurrencyService_ConcurrentReads(t *testing.T) {
	svc := newTestCurrencyService()
	done := make(chan struct{})
	for i := 0; i < 10; i++ {
		go func() {
			_, _ = svc.ListAll(context.Background(), &ledgerV1.ListAllCurrencyRequest{})
			_, _ = svc.Convert(context.Background(), &ledgerV1.ConvertCurrencyRequest{
				Amount: "1", From: "USD", To: "CNY",
			})
			done <- struct{}{}
		}()
	}
	for i := 0; i < 10; i++ {
		<-done
	}
}

// ─── findRate helper ──────────────────────────────────

func TestCurrencyService_findRate(t *testing.T) {
	svc := newTestCurrencyService()
	assert.InDelta(t, 7.2, svc.findRate("CNY"), 0.01)
	assert.InDelta(t, 1.0, svc.findRate("USD"), 0.01)
	assert.InDelta(t, 0.0, svc.findRate("XXX"), 0.01)
}

// ─── parseFloat / formatFloat roundtrip ───────────────

func TestParseFloat_FormatFloat_Roundtrip(t *testing.T) {
	tests := []struct {
		input string
		want  float64
	}{
		{"7.2", 7.2},
		{"0", 0},
		{"148.0", 148.0},
		{"not-a-number", 0},
		{"", 0},
	}
	for _, tt := range tests {
		t.Run(tt.input, func(t *testing.T) {
			got := parseFloat(tt.input)
			assert.InDelta(t, tt.want, got, 0.001)
		})
	}
}

func TestFormatFloat(t *testing.T) {
	assert.Equal(t, "7.2", formatFloat(7.2))
	assert.Equal(t, "0", formatFloat(0))
}
