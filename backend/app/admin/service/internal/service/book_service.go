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

type BookService struct {
	adminV1.BookServiceHTTPServer
	client ledgerV1.BookServiceClient
	log    *log.Helper
}

func NewBookService(ctx *bootstrap.Context, client ledgerV1.BookServiceClient) *BookService {
	return &BookService{
		log:    ctx.NewLoggerHelper("book/service/admin-service"),
		client: client,
	}
}

func (s *BookService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListBookResponse, error) {
	return s.client.List(ctx, req)
}

func (s *BookService) Get(ctx context.Context, req *ledgerV1.GetBookRequest) (*ledgerV1.Book, error) {
	return s.client.Get(ctx, req)
}

func (s *BookService) Create(ctx context.Context, req *ledgerV1.CreateBookRequest) (*ledgerV1.Book, error) {
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

func (s *BookService) Update(ctx context.Context, req *ledgerV1.UpdateBookRequest) (*ledgerV1.Book, error) {
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

func (s *BookService) Delete(ctx context.Context, req *ledgerV1.DeleteBookRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}

func (s *BookService) ListAll(ctx context.Context, req *ledgerV1.ListAllBookRequest) (*ledgerV1.ListBookResponse, error) {
	return s.client.ListAll(ctx, req)
}

func (s *BookService) Toggle(ctx context.Context, req *ledgerV1.ToggleBookRequest) (*ledgerV1.Book, error) {
	return s.client.Toggle(ctx, req)
}
