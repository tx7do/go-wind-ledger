package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	appV1 "go-wind-cms/api/gen/go/app/service/v1"
	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type AccountService struct {
	appV1.AccountServiceHTTPServer

	client ledgerV1.AccountServiceClient
	log    *log.Helper
}

func NewAccountService(ctx *bootstrap.Context, client ledgerV1.AccountServiceClient) *AccountService {
	return &AccountService{
		log:    ctx.NewLoggerHelper("account/service/app-service"),
		client: client,
	}
}

func (s *AccountService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListAccountResponse, error) {
	return s.client.List(ctx, req)
}

func (s *AccountService) ListAll(ctx context.Context, req *ledgerV1.ListAllAccountRequest) (*ledgerV1.ListAccountResponse, error) {
	return s.client.ListAll(ctx, req)
}

func (s *AccountService) Get(ctx context.Context, req *ledgerV1.GetAccountRequest) (*ledgerV1.Account, error) {
	return s.client.Get(ctx, req)
}

func (s *AccountService) Create(ctx context.Context, req *ledgerV1.CreateAccountRequest) (*ledgerV1.Account, error) {
	return s.client.Create(ctx, req)
}

func (s *AccountService) Update(ctx context.Context, req *ledgerV1.UpdateAccountRequest) (*ledgerV1.Account, error) {
	return s.client.Update(ctx, req)
}

func (s *AccountService) Delete(ctx context.Context, req *ledgerV1.DeleteAccountRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}

func (s *AccountService) Toggle(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.client.Toggle(ctx, req)
}

func (s *AccountService) ToggleInclude(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.client.ToggleInclude(ctx, req)
}

func (s *AccountService) ToggleCanExpense(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.client.ToggleCanExpense(ctx, req)
}

func (s *AccountService) ToggleCanIncome(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.client.ToggleCanIncome(ctx, req)
}

func (s *AccountService) ToggleCanTransferFrom(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.client.ToggleCanTransferFrom(ctx, req)
}

func (s *AccountService) ToggleCanTransferTo(ctx context.Context, req *ledgerV1.ToggleAccountRequest) (*ledgerV1.Account, error) {
	return s.client.ToggleCanTransferTo(ctx, req)
}

func (s *AccountService) AdjustBalance(ctx context.Context, req *ledgerV1.AdjustBalanceRequest) (*ledgerV1.Account, error) {
	return s.client.AdjustBalance(ctx, req)
}
