package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	"go-wind-cms/app/core/service/internal/data"

	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type BookService struct {
	ledgerV1.UnimplementedBookServiceServer
	bookRepo *data.BookRepo
	log      *log.Helper
}

func NewBookService(ctx *bootstrap.Context, bookRepo *data.BookRepo) *BookService {
	return &BookService{
		log:      ctx.NewLoggerHelper("book/service/core-service"),
		bookRepo: bookRepo,
	}
}

func (s *BookService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListBookResponse, error) {
	return s.bookRepo.List(ctx, req)
}

func (s *BookService) ListAll(ctx context.Context, req *ledgerV1.ListAllBookRequest) (*ledgerV1.ListBookResponse, error) {
	return s.bookRepo.ListAll(ctx, req.GetIncludeDisabled())
}

func (s *BookService) Get(ctx context.Context, req *ledgerV1.GetBookRequest) (*ledgerV1.Book, error) {
	return s.bookRepo.Get(ctx, req.GetId())
}

func (s *BookService) Create(ctx context.Context, req *ledgerV1.CreateBookRequest) (*ledgerV1.Book, error) {
	if req.Data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	return s.bookRepo.Create(ctx, req.Data)
}

func (s *BookService) Update(ctx context.Context, req *ledgerV1.UpdateBookRequest) (*ledgerV1.Book, error) {
	return s.bookRepo.Update(ctx, req.GetId(), req.Data, req.GetUpdateMask())
}

func (s *BookService) Delete(ctx context.Context, req *ledgerV1.DeleteBookRequest) (*emptypb.Empty, error) {
	if err := s.bookRepo.Delete(ctx, req.GetId()); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

func (s *BookService) Toggle(ctx context.Context, req *ledgerV1.ToggleBookRequest) (*ledgerV1.Book, error) {
	return s.bookRepo.Toggle(ctx, req.GetId())
}
