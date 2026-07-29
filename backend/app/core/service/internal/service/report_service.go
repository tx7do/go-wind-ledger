package service

import (
	"context"
	"sort"
	"strconv"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-ledger/app/core/service/internal/data"
	"go-wind-ledger/app/core/service/internal/data/ent"
	"go-wind-ledger/app/core/service/internal/data/ent/account"
	"go-wind-ledger/app/core/service/internal/data/ent/balanceflow"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

type ReportService struct {
	ledgerV1.UnimplementedReportServiceServer
	flowRepo    *data.BalanceFlowRepo
	accountRepo *data.AccountRepo
	log         *log.Helper
}

func NewReportService(ctx *bootstrap.Context, flowRepo *data.BalanceFlowRepo, accountRepo *data.AccountRepo) *ReportService {
	return &ReportService{
		log:         ctx.NewLoggerHelper("report/service/core-service"),
		flowRepo:    flowRepo,
		accountRepo: accountRepo,
	}
}

// reportByCategory aggregates flow amounts grouped by category.
func (s *ReportService) reportByCategory(ctx context.Context, req *ledgerV1.ReportQueryRequest, flowType balanceflow.Type) (*ledgerV1.ReportResponse, error) {
	flows, err := s.flowRepo.QueryFlowsByType(ctx, req.GetBookId(), flowType)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query flows failed")
	}
	if len(flows) == 0 {
		return &ledgerV1.ReportResponse{}, nil
	}

	flowIDs := make([]uint32, 0, len(flows))
	for _, f := range flows {
		flowIDs = append(flowIDs, f.ID)
	}

	relations, err := s.flowRepo.QueryCategoryRelationsByFlowIDs(ctx, flowIDs)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query category relations failed")
	}

	// Sum by category ID
	categorySums := make(map[uint32]float64)
	for _, rel := range relations {
		if rel.ConvertedAmount != nil && rel.CategoryID != nil {
			categorySums[*rel.CategoryID] += *rel.ConvertedAmount
		}
	}

	// Get category names
	categories, _ := s.flowRepo.QueryAllCategories(ctx)
	categoryNames := make(map[uint32]string)
	for _, c := range categories {
		if c.Name != nil {
			categoryNames[c.ID] = *c.Name
		}
	}

	points := s.buildChartPoints(categorySums, categoryNames)
	return &ledgerV1.ReportResponse{Items: points}, nil
}

// reportByTag aggregates flow amounts grouped by tag.
func (s *ReportService) reportByTag(ctx context.Context, req *ledgerV1.ReportQueryRequest, flowType balanceflow.Type) (*ledgerV1.ReportResponse, error) {
	flows, err := s.flowRepo.QueryFlowsByType(ctx, req.GetBookId(), flowType)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query flows failed")
	}
	if len(flows) == 0 {
		return &ledgerV1.ReportResponse{}, nil
	}

	flowIDs := make([]uint32, 0, len(flows))
	for _, f := range flows {
		flowIDs = append(flowIDs, f.ID)
	}

	relations, err := s.flowRepo.QueryTagRelationsByFlowIDs(ctx, flowIDs)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query tag relations failed")
	}

	tagSums := make(map[uint32]float64)
	for _, rel := range relations {
		if rel.ConvertedAmount != nil && rel.TagID != nil {
			tagSums[*rel.TagID] += *rel.ConvertedAmount
		}
	}

	tags, _ := s.flowRepo.QueryAllTags(ctx)
	tagNames := make(map[uint32]string)
	for _, t := range tags {
		if t.Name != nil {
			tagNames[t.ID] = *t.Name
		}
	}

	points := s.buildChartPoints(tagSums, tagNames)
	return &ledgerV1.ReportResponse{Items: points}, nil
}

// reportByPayee aggregates flow amounts grouped by payee.
func (s *ReportService) reportByPayee(ctx context.Context, req *ledgerV1.ReportQueryRequest, flowType balanceflow.Type) (*ledgerV1.ReportResponse, error) {
	flows, err := s.flowRepo.QueryFlowsByType(ctx, req.GetBookId(), flowType)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query flows failed")
	}
	if len(flows) == 0 {
		return &ledgerV1.ReportResponse{}, nil
	}

	// Sum by payee ID directly from flows
	payeeSums := make(map[uint32]float64)
	for _, f := range flows {
		if f.PayeeID != nil && f.ConvertedAmount != nil {
			payeeSums[*f.PayeeID] += *f.ConvertedAmount
		}
	}

	payees, _ := s.flowRepo.QueryAllPayees(ctx)
	payeeNames := make(map[uint32]string)
	for _, p := range payees {
		if p.Name != nil {
			payeeNames[p.ID] = *p.Name
		}
	}

	points := s.buildChartPoints(payeeSums, payeeNames)
	return &ledgerV1.ReportResponse{Items: points}, nil
}

// buildChartPoints converts a map of id->amount into sorted ChartPoint slice with percentages.
func (s *ReportService) buildChartPoints(sums map[uint32]float64, names map[uint32]string) []*ledgerV1.ChartPoint {
	var total float64
	for _, v := range sums {
		total += v
	}

	type item struct {
		name   string
		amount float64
	}
	items := make([]item, 0, len(sums))
	for id, amount := range sums {
		name := names[id]
		if name == "" {
			name = "Unknown"
		}
		items = append(items, item{name: name, amount: amount})
	}
	sort.Slice(items, func(i, j int) bool {
		return items[i].amount > items[j].amount
	})

	points := make([]*ledgerV1.ChartPoint, 0, len(items))
	for _, it := range items {
		pct := "0"
		if total > 0 {
			pct = strconv.FormatFloat(it.amount/total*100, 'f', 2, 64)
		}
		points = append(points, &ledgerV1.ChartPoint{
			X:       it.name,
			Y:       strconv.FormatFloat(it.amount, 'f', 2, 64),
			Percent: pct,
		})
	}
	return points
}

func (s *ReportService) ExpenseCategory(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.reportByCategory(ctx, req, balanceflow.TypeFlowTypeExpense)
}

func (s *ReportService) IncomeCategory(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.reportByCategory(ctx, req, balanceflow.TypeFlowTypeIncome)
}

func (s *ReportService) ExpenseTag(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.reportByTag(ctx, req, balanceflow.TypeFlowTypeExpense)
}

func (s *ReportService) IncomeTag(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.reportByTag(ctx, req, balanceflow.TypeFlowTypeIncome)
}

func (s *ReportService) ExpensePayee(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.reportByPayee(ctx, req, balanceflow.TypeFlowTypeExpense)
}

func (s *ReportService) IncomePayee(ctx context.Context, req *ledgerV1.ReportQueryRequest) (*ledgerV1.ReportResponse, error) {
	return s.reportByPayee(ctx, req, balanceflow.TypeFlowTypeIncome)
}

// Balance returns assets vs debts breakdown.
func (s *ReportService) Balance(ctx context.Context, req *ledgerV1.BalanceReportRequest) (*ledgerV1.BalanceReportResponse, error) {
	accounts, err := s.flowRepo.QueryEnabledAccounts(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query accounts failed")
	}

	var assetPoints []*ledgerV1.ChartPoint
	var debtPoints []*ledgerV1.ChartPoint
	var totalAssets, totalDebts float64

	for _, acct := range accounts {
		if acct.Balance == nil || *acct.Balance == 0 {
			continue
		}
		balance := *acct.Balance
		name := "Unknown"
		if acct.Name != nil {
			name = *acct.Name
		}

		switch *acct.Type {
		case account.TypeAccountTypeChecking, account.TypeAccountTypeAsset:
			assetPoints = append(assetPoints, &ledgerV1.ChartPoint{
				X: name,
				Y: strconv.FormatFloat(balance, 'f', 2, 64),
			})
			totalAssets += balance
		case account.TypeAccountTypeCredit, account.TypeAccountTypeDebt:
			debtPoints = append(debtPoints, &ledgerV1.ChartPoint{
				X: name,
				Y: strconv.FormatFloat(-balance, 'f', 2, 64),
			})
			totalDebts += -balance
		}
	}

	netWorth := totalAssets + totalDebts // debts are negative
	return &ledgerV1.BalanceReportResponse{
		Assets:   assetPoints,
		Debts:    debtPoints,
		NetWorth: strconv.FormatFloat(netWorth, 'f', 2, 64),
	}, nil
}

// Suppress unused import warning
var _ = ent.IsNotFound
