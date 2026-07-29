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

type BookService struct {
	appV1.BookServiceHTTPServer

	client ledgerV1.BookServiceClient
	log    *log.Helper
}

func NewBookService(ctx *bootstrap.Context, client ledgerV1.BookServiceClient) *BookService {
	return &BookService{
		log:    ctx.NewLoggerHelper("book/service/app-service"),
		client: client,
	}
}

func (s *BookService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListBookResponse, error) {
	return s.client.List(ctx, req)
}

func (s *BookService) ListAll(ctx context.Context, req *ledgerV1.ListAllBookRequest) (*ledgerV1.ListBookResponse, error) {
	return s.client.ListAll(ctx, req)
}

func (s *BookService) Get(ctx context.Context, req *ledgerV1.GetBookRequest) (*ledgerV1.Book, error) {
	return s.client.Get(ctx, req)
}

func (s *BookService) Create(ctx context.Context, req *ledgerV1.CreateBookRequest) (*ledgerV1.Book, error) {
	return s.client.Create(ctx, req)
}

func (s *BookService) Update(ctx context.Context, req *ledgerV1.UpdateBookRequest) (*ledgerV1.Book, error) {
	return s.client.Update(ctx, req)
}

func (s *BookService) Delete(ctx context.Context, req *ledgerV1.DeleteBookRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}

func (s *BookService) Toggle(ctx context.Context, req *ledgerV1.ToggleBookRequest) (*ledgerV1.Book, error) {
	return s.client.Toggle(ctx, req)
}

func (s *BookService) Export(ctx context.Context, req *ledgerV1.ExportBookRequest) (*ledgerV1.ExportBookResponse, error) {
	return s.client.Export(ctx, req)
}

func (s *BookService) ListAllBooks(ctx context.Context, req *emptypb.Empty) (*ledgerV1.ListBookResponse, error) {
	return s.client.ListAllBooks(ctx, req)
}

func (s *BookService) CreateByTemplate(ctx context.Context, req *ledgerV1.CreateBookByTemplateRequest) (*ledgerV1.Book, error) {
	return s.client.CreateByTemplate(ctx, req)
}

func (s *BookService) Copy(ctx context.Context, req *ledgerV1.CopyBookRequest) (*ledgerV1.Book, error) {
	return s.client.Copy(ctx, req)
}
