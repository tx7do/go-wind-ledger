package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	"go-wind-ledger/app/core/service/internal/data"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

type AccountService struct {
	ledgerV1.UnimplementedAccountServiceServer
	accountRepo *data.AccountRepo
	flowRepo    *data.BalanceFlowRepo
	log         *log.Helper
}

func NewAccountService(ctx *bootstrap.Context, accountRepo *data.AccountRepo, flowRepo *data.BalanceFlowRepo) *AccountService {
	return &AccountService{
		log:         ctx.NewLoggerHelper("account/service/core-service"),
		accountRepo: accountRepo,
		flowRepo:    flowRepo,
	}
}

func (s *AccountService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListAccountResponse, error) {
	return s.accountRepo.List(ctx, req)
}

func (s *AccountService) ListAll(ctx context.Context, req *ledgerV1.ListAllAccountRequest) (*ledgerV1.ListAccountResponse, error) {
	return s.accountRepo.ListAll(ctx, req.GetIncludeDisabled())
}

func (s *AccountService) Get(ctx context.Context, req *ledgerV1.GetAccountRequest) (*ledgerV1.Account, error) {
	return s.accountRepo.Get(ctx, req.GetId())
}

func (s *AccountService) Create(ctx context.Context, req *ledgerV1.CreateAccountRequest) (*ledgerV1.Account, error) {
	if req.Data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	return s.accountRepo.Create(ctx, req.Data)
}

func (s *AccountService) Update(ctx context.Context, req *ledgerV1.UpdateAccountRequest) (*ledgerV1.Account, error) {
	return s.accountRepo.Update(ctx, req.GetId(), req.Data, req.GetUpdateMask())
}

func (s *AccountService) Delete(ctx context.Context, req *ledgerV1.DeleteAccountRequest) (*emptypb.Empty, error) {
	if err := s.accountRepo.Delete(ctx, req.GetId()); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

func (s *AccountService) Toggle(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.accountRepo.Toggle(ctx, req.GetId())
}

func (s *AccountService) ToggleInclude(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.accountRepo.ToggleInclude(ctx, req.GetId())
}

func (s *AccountService) ToggleCanExpense(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.accountRepo.ToggleCanExpense(ctx, req.GetId())
}

func (s *AccountService) ToggleCanIncome(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.accountRepo.ToggleCanIncome(ctx, req.GetId())
}

func (s *AccountService) ToggleCanTransferFrom(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.accountRepo.ToggleCanTransferFrom(ctx, req.GetId())
}

func (s *AccountService) ToggleCanTransferTo(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.accountRepo.ToggleCanTransferTo(ctx, req.GetId())
}

// AdjustBalance implements balance adjustment with ADJUST flow creation.
// Maps to Java AccountService.adjustBalance.
func (s *AccountService) AdjustBalance(ctx context.Context, req *ledgerV1.AdjustBalanceRequest) (*ledgerV1.Account, error) {
	// Get current account
	acct, err := s.accountRepo.Get(ctx, req.GetId())
	if err != nil {
		return nil, err
	}

	newBalance := req.GetBalance()
	oldBalance := acct.GetBalance()

	// Update account balance
	if err := s.accountRepo.UpdateBalance(ctx, req.GetId(), data.StrToFloat(newBalance)); err != nil {
		return nil, ledgerV1.ErrorInternalServerError("update balance failed")
	}

	// Create ADJUST flow record to document the balance change
	confirmTrue := true
	includeTrue := true
	createTime := req.GetCreateTime()

	adjustFlow := &ledgerV1.BalanceFlow{
		Type:      ledgerV1.FlowType_FLOW_TYPE_ADJUST.Enum(),
		AccountId: &req.Id,
		Amount:    &newBalance, // The new balance is stored as amount for ADJUST
		BookId:    &req.BookId,
		Title:     req.Title,
		Notes:     req.Notes,
		Confirm:   &confirmTrue,
		Include:   &includeTrue,
		CreateTime: &createTime,
	}

	if _, err := s.flowRepo.CreateFlow(ctx, adjustFlow); err != nil {
		s.log.Errorf("failed to create ADJUST flow for balance change: old=%.2f new=%.2f: %s", oldBalance, newBalance, err.Error())
		// Attempt to rollback the balance change
		_ = s.accountRepo.UpdateBalance(ctx, req.GetId(), data.StrToFloat(oldBalance))
		return nil, ledgerV1.ErrorInternalServerError("create adjust flow failed, balance rolled back")
	}

	return s.accountRepo.Get(ctx, req.GetId())

}

// Overview returns an aggregated view of assets and debts across all enabled,
// statistics-included accounts.
func (s *AccountService) Overview(ctx context.Context, req *ledgerV1.OverviewRequest) (*ledgerV1.OverviewResponse, error) {
	return s.accountRepo.Overview(ctx)
}

// Statistics returns aggregated balance/credit figures across all enabled
// accounts, optionally filtered by currency code.
func (s *AccountService) Statistics(ctx context.Context, req *ledgerV1.AccountStatisticsRequest) (*ledgerV1.AccountStatisticsResponse, error) {
	return s.accountRepo.Statistics(ctx, req.GetCurrencyCode())
}
