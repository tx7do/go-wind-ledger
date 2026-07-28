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

type CategoryService struct {
	adminV1.CategoryServiceHTTPServer
	client ledgerV1.CategoryServiceClient
	log    *log.Helper
}

func NewCategoryService(ctx *bootstrap.Context, client ledgerV1.CategoryServiceClient) *CategoryService {
	return &CategoryService{
		log:    ctx.NewLoggerHelper("category/service/admin-service"),
		client: client,
	}
}

func (s *CategoryService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListCategoryResponse, error) {
	return s.client.List(ctx, req)
}

func (s *CategoryService) Get(ctx context.Context, req *ledgerV1.GetCategoryRequest) (*ledgerV1.Category, error) {
	return s.client.Get(ctx, req)
}

func (s *CategoryService) Create(ctx context.Context, req *ledgerV1.CreateCategoryRequest) (*ledgerV1.Category, error) {
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

func (s *CategoryService) Update(ctx context.Context, req *ledgerV1.UpdateCategoryRequest) (*ledgerV1.Category, error) {
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

func (s *CategoryService) Delete(ctx context.Context, req *ledgerV1.DeleteCategoryRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}

func (s *CategoryService) ListAll(ctx context.Context, req *ledgerV1.ListAllCategoryRequest) (*ledgerV1.ListCategoryResponse, error) {
	return s.client.ListAll(ctx, req)
}

func (s *CategoryService) Toggle(ctx context.Context, req *ledgerV1.ToggleCategoryRequest) (*ledgerV1.Category, error) {
	return s.client.Toggle(ctx, req)
}
