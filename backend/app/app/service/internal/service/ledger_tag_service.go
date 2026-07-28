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

type LedgerTagService struct {
	appV1.LedgerTagServiceHTTPServer

	client ledgerV1.TagServiceClient
	log    *log.Helper
}

func NewLedgerTagService(ctx *bootstrap.Context, client ledgerV1.TagServiceClient) *LedgerTagService {
	return &LedgerTagService{
		log:    ctx.NewLoggerHelper("ledger-tag/service/app-service"),
		client: client,
	}
}

func (s *LedgerTagService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListTagResponse, error) {
	return s.client.List(ctx, req)
}

func (s *LedgerTagService) ListAll(ctx context.Context, req *ledgerV1.ListAllTagRequest) (*ledgerV1.ListTagResponse, error) {
	return s.client.ListAll(ctx, req)
}

func (s *LedgerTagService) Get(ctx context.Context, req *ledgerV1.GetTagRequest) (*ledgerV1.Tag, error) {
	return s.client.Get(ctx, req)
}

func (s *LedgerTagService) Create(ctx context.Context, req *ledgerV1.CreateTagRequest) (*ledgerV1.Tag, error) {
	return s.client.Create(ctx, req)
}

func (s *LedgerTagService) Update(ctx context.Context, req *ledgerV1.UpdateTagRequest) (*ledgerV1.Tag, error) {
	return s.client.Update(ctx, req)
}

func (s *LedgerTagService) Delete(ctx context.Context, req *ledgerV1.DeleteTagRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}

func (s *LedgerTagService) Toggle(ctx context.Context, req *ledgerV1.ToggleTagRequest) (*ledgerV1.Tag, error) {
	return s.client.Toggle(ctx, req)
}
