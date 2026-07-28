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

type TagService struct {
	adminV1.TagServiceHTTPServer
	client ledgerV1.TagServiceClient
	log    *log.Helper
}

func NewTagService(ctx *bootstrap.Context, client ledgerV1.TagServiceClient) *TagService {
	return &TagService{
		log:    ctx.NewLoggerHelper("tag/service/admin-service"),
		client: client,
	}
}

func (s *TagService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListTagResponse, error) {
	return s.client.List(ctx, req)
}

func (s *TagService) Get(ctx context.Context, req *ledgerV1.GetTagRequest) (*ledgerV1.Tag, error) {
	return s.client.Get(ctx, req)
}

func (s *TagService) Create(ctx context.Context, req *ledgerV1.CreateTagRequest) (*ledgerV1.Tag, error) {
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

func (s *TagService) Update(ctx context.Context, req *ledgerV1.UpdateTagRequest) (*ledgerV1.Tag, error) {
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

func (s *TagService) Delete(ctx context.Context, req *ledgerV1.DeleteTagRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}

func (s *TagService) ListAll(ctx context.Context, req *ledgerV1.ListAllTagRequest) (*ledgerV1.ListTagResponse, error) {
	return s.client.ListAll(ctx, req)
}

func (s *TagService) Toggle(ctx context.Context, req *ledgerV1.ToggleTagRequest) (*ledgerV1.Tag, error) {
	return s.client.Toggle(ctx, req)
}
