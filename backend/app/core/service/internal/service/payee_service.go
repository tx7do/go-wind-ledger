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

type PayeeService struct {
	ledgerV1.UnimplementedPayeeServiceServer
	payeeRepo *data.PayeeRepo
	log       *log.Helper
}

func NewPayeeService(ctx *bootstrap.Context, payeeRepo *data.PayeeRepo) *PayeeService {
	return &PayeeService{
		log:       ctx.NewLoggerHelper("payee/service/core-service"),
		payeeRepo: payeeRepo,
	}
}

func (s *PayeeService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListPayeeResponse, error) {
	return s.payeeRepo.List(ctx, req)
}

func (s *PayeeService) ListAll(ctx context.Context, req *ledgerV1.ListAllPayeeRequest) (*ledgerV1.ListPayeeResponse, error) {
	return s.payeeRepo.ListAll(ctx, req.GetBookId())
}

func (s *PayeeService) Get(ctx context.Context, req *ledgerV1.GetPayeeRequest) (*ledgerV1.Payee, error) {
	return s.payeeRepo.Get(ctx, req.GetId())
}

func (s *PayeeService) Create(ctx context.Context, req *ledgerV1.CreatePayeeRequest) (*ledgerV1.Payee, error) {
	if req.Data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	return s.payeeRepo.Create(ctx, req.Data)
}

func (s *PayeeService) Update(ctx context.Context, req *ledgerV1.UpdatePayeeRequest) (*ledgerV1.Payee, error) {
	return s.payeeRepo.Update(ctx, req.GetId(), req.Data, req.GetUpdateMask())
}

func (s *PayeeService) Delete(ctx context.Context, req *ledgerV1.DeletePayeeRequest) (*emptypb.Empty, error) {
	if err := s.payeeRepo.Delete(ctx, req.GetId()); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

func (s *PayeeService) Toggle(ctx context.Context, req *ledgerV1.TogglePayeeRequest) (*ledgerV1.Payee, error) {
	return s.payeeRepo.Toggle(ctx, req.GetId())
}

func (s *PayeeService) ToggleCanExpense(ctx context.Context, req *ledgerV1.TogglePayeeRequest) (*ledgerV1.Payee, error) {
	return s.payeeRepo.ToggleCanExpense(ctx, req.GetId())
}

func (s *PayeeService) ToggleCanIncome(ctx context.Context, req *ledgerV1.TogglePayeeRequest) (*ledgerV1.Payee, error) {
	return s.payeeRepo.ToggleCanIncome(ctx, req.GetId())
}
