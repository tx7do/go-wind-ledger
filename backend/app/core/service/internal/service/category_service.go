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

type CategoryService struct {
	ledgerV1.UnimplementedCategoryServiceServer
	categoryRepo *data.CategoryRepo
	log          *log.Helper
}

func NewCategoryService(ctx *bootstrap.Context, categoryRepo *data.CategoryRepo) *CategoryService {
	return &CategoryService{
		log:          ctx.NewLoggerHelper("category/service/core-service"),
		categoryRepo: categoryRepo,
	}
}

func (s *CategoryService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListCategoryResponse, error) {
	return s.categoryRepo.List(ctx, req)
}

func (s *CategoryService) ListAll(ctx context.Context, req *ledgerV1.ListAllCategoryRequest) (*ledgerV1.ListCategoryResponse, error) {
	return s.categoryRepo.ListAll(ctx, req.GetBookId(), req.Type)
}

func (s *CategoryService) Get(ctx context.Context, req *ledgerV1.GetCategoryRequest) (*ledgerV1.Category, error) {
	return s.categoryRepo.Get(ctx, req.GetId())
}

func (s *CategoryService) Create(ctx context.Context, req *ledgerV1.CreateCategoryRequest) (*ledgerV1.Category, error) {
	if req.Data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	return s.categoryRepo.Create(ctx, req.Data)
}

func (s *CategoryService) Update(ctx context.Context, req *ledgerV1.UpdateCategoryRequest) (*ledgerV1.Category, error) {
	return s.categoryRepo.Update(ctx, req.GetId(), req.Data, req.GetUpdateMask())
}

func (s *CategoryService) Delete(ctx context.Context, req *ledgerV1.DeleteCategoryRequest) (*emptypb.Empty, error) {
	if err := s.categoryRepo.Delete(ctx, req.GetId()); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

func (s *CategoryService) Toggle(ctx context.Context, req *ledgerV1.ToggleCategoryRequest) (*ledgerV1.Category, error) {
	return s.categoryRepo.Toggle(ctx, req.GetId())
}
