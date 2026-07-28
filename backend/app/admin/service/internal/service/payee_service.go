package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/go-utils/trans"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	adminV1 "go-wind-cms/api/gen/go/admin/service/v1"
	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"

	"go-wind-cms/pkg/middleware/auth"
)

type PayeeService struct {
	adminV1.PayeeServiceHTTPServer
	client ledgerV1.PayeeServiceClient
	log    *log.Helper
}

func NewPayeeService(ctx *bootstrap.Context, client ledgerV1.PayeeServiceClient) *PayeeService {
	return &PayeeService{
		log:    ctx.NewLoggerHelper("payee/service/admin-service"),
		client: client,
	}
}

func (s *PayeeService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListPayeeResponse, error) {
	return s.client.List(ctx, req)
}

func (s *PayeeService) Get(ctx context.Context, req *ledgerV1.GetPayeeRequest) (*ledgerV1.Payee, error) {
	return s.client.Get(ctx, req)
}

func (s *PayeeService) Create(ctx context.Context, req *ledgerV1.CreatePayeeRequest) (*ledgerV1.Payee, error) {
	if req.Data == nil {
		return nil, adminV1.ErrorBadRequest("invalid parameter")
	}
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}
	req.Data.CreatedBy = trans.Ptr(operator.UserId)
	return s.client.Create(ctx, req)
}

func (s *PayeeService) Update(ctx context.Context, req *ledgerV1.UpdatePayeeRequest) (*ledgerV1.Payee, error) {
	if req.Data == nil {
		return nil, adminV1.ErrorBadRequest("invalid parameter")
	}
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}
	req.Data.UpdatedBy = trans.Ptr(operator.GetUserId())
	if req.UpdateMask != nil {
		req.UpdateMask.Paths = append(req.UpdateMask.Paths, "updated_by")
	}
	return s.client.Update(ctx, req)
}

func (s *PayeeService) Delete(ctx context.Context, req *ledgerV1.DeletePayeeRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}

func (s *PayeeService) ListAll(ctx context.Context, req *ledgerV1.ListAllPayeeRequest) (*ledgerV1.ListPayeeResponse, error) {
	return s.client.ListAll(ctx, req)
}

func (s *PayeeService) Toggle(ctx context.Context, req *ledgerV1.TogglePayeeRequest) (*ledgerV1.Payee, error) {
	return s.client.Toggle(ctx, req)
}
