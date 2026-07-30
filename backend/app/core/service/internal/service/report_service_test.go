package service

import (
	"context"
	"sort"
	"strconv"
	"testing"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/stretchr/testify/assert"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

func newTestReportService() *ReportService {
	return &ReportService{log: log.NewHelper(log.DefaultLogger)}
}

// ─── buildChartPoints ─────────────────────────────────

func TestBuildChartPoints_SingleItem(t *testing.T) {
	svc := newTestReportService()
	points := svc.buildChartPoints(
		map[uint32]float64{1: 100.0},
		map[uint32]string{1: "Food"},
	)
	assert.Len(t, points, 1)
	assert.Equal(t, "Food", points[0].X)
	assert.Equal(t, "100.00", points[0].Y)
	assert.Equal(t, "100.00", points[0].Percent)
}

func TestBuildChartPoints_MultipleItems_SortedByAmountDesc(t *testing.T) {
	svc := newTestReportService()
	points := svc.buildChartPoints(
		map[uint32]float64{
			1: 50.0,
			2: 200.0,
			3: 150.0,
		},
		map[uint32]string{1: "A", 2: "B", 3: "C"},
	)
	assert.Len(t, points, 3)
	assert.Equal(t, "B", points[0].X) // 200
	assert.Equal(t, "C", points[1].X) // 150
	assert.Equal(t, "A", points[2].X) // 50
}

func TestBuildChartPoints_Percentages(t *testing.T) {
	svc := newTestReportService()
	points := svc.buildChartPoints(
		map[uint32]float64{1: 25.0, 2: 75.0},
		map[uint32]string{1: "X", 2: "Y"},
	)
	assert.Len(t, points, 2)
	// 75% (largest first)
	assert.Equal(t, "75.00", points[0].Percent)
	assert.Equal(t, "25.00", points[1].Percent)
}

func TestBuildChartPoints_UnknownName(t *testing.T) {
	svc := newTestReportService()
	points := svc.buildChartPoints(
		map[uint32]float64{1: 42.0},
		map[uint32]string{}, // no name mapping
	)
	assert.Len(t, points, 1)
	assert.Equal(t, "Unknown", points[0].X)
	assert.Equal(t, "100.00", points[0].Percent)
}

func TestBuildChartPoints_EmptyInput(t *testing.T) {
	svc := newTestReportService()
	points := svc.buildChartPoints(
		map[uint32]float64{},
		map[uint32]string{},
	)
	assert.Empty(t, points)
}

func TestBuildChartPoints_ZeroAmount(t *testing.T) {
	svc := newTestReportService()
	points := svc.buildChartPoints(
		map[uint32]float64{1: 0, 2: 0},
		map[uint32]string{1: "A", 2: "B"},
	)
	assert.Len(t, points, 2)
	// All percentages should be "0" when total is 0
	assert.Equal(t, "0", points[0].Percent)
	assert.Equal(t, "0", points[1].Percent)
}

func TestBuildChartPoints_NegativeAmounts(t *testing.T) {
	svc := newTestReportService()
	points := svc.buildChartPoints(
		map[uint32]float64{1: -100.0, 2: 50.0},
		map[uint32]string{1: "Loss", 2: "Gain"},
	)
	assert.Len(t, points, 2)
	// Sorted by amount desc: 50 first, -100 second
	assert.Equal(t, "Gain", points[0].X)
	assert.Equal(t, "Loss", points[1].X)
}

func TestBuildChartPoints_AmountFormatting(t *testing.T) {
	svc := newTestReportService()
	points := svc.buildChartPoints(
		map[uint32]float64{1: 123.456},
		map[uint32]string{1: "Item"},
	)
	assert.Len(t, points, 1)
	assert.Equal(t, "123.46", points[0].Y) // rounded to 2 decimal places
}

// ─── Balance logic (net worth calculation) ────────────

// TestBalanceCalculation verifies net worth = totalAssets + totalDebts (debts negative)
func TestBalanceCalculation(t *testing.T) {
	// Simulate the logic from Balance() method's net worth calculation
	assets := 1000.0
	debts := -300.0 // negative representation
	netWorth := assets + debts
	assert.InDelta(t, 700.0, netWorth, 0.01)
	assert.Equal(t, "700.00", strconv.FormatFloat(netWorth, 'f', 2, 64))
}

func TestBalanceCalculation_MoreDebtThanAssets(t *testing.T) {
	assets := 500.0
	debts := -800.0
	netWorth := assets + debts
	assert.InDelta(t, -300.0, netWorth, 0.01)
}

// ─── ChartPoint sorting verification ──────────────────

func TestChartPointSortOrder(t *testing.T) {
	// Verify sort.Slice sorts correctly for our use case
	items := []struct {
		name   string
		amount float64
	}{
		{"C", 30}, {"A", 100}, {"B", 75},
	}
	sort.Slice(items, func(i, j int) bool {
		return items[i].amount > items[j].amount
	})
	assert.Equal(t, "A", items[0].name)
	assert.Equal(t, "B", items[1].name)
	assert.Equal(t, "C", items[2].name)
}

// ─── Currency-specific tests ──────────────────────────

func TestCurrencyService_EdgeCases(t *testing.T) {
	svc := newTestCurrencyService()

	// Convert with zero amount
	resp, err := svc.Convert(context.Background(), &ledgerV1.ConvertCurrencyRequest{
		Amount: "0",
		From:   "USD",
		To:     "CNY",
	})
	assert.NoError(t, err)
	assert.Equal(t, "0", resp.GetAmount())

	// Convert with very large amount
	resp, err = svc.Convert(context.Background(), &ledgerV1.ConvertCurrencyRequest{
		Amount: "999999999",
		From:   "USD",
		To:     "JPY",
	})
	assert.NoError(t, err)
	assert.NotEmpty(t, resp.GetAmount())
}
