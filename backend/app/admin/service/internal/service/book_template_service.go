package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	adminV1 "go-wind-ledger/api/gen/go/admin/service/v1"
	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

// BookTemplateService 账本模板服务（Admin BFF）
// 转发至 core 服务 BookTemplateService。
type BookTemplateService struct {
	adminV1.BookTemplateServiceHTTPServer

	client ledgerV1.BookTemplateServiceClient
	log    *log.Helper
}

func NewBookTemplateService(ctx *bootstrap.Context, client ledgerV1.BookTemplateServiceClient) *BookTemplateService {
	return &BookTemplateService{
		log:    ctx.NewLoggerHelper("book_template/service/admin-service"),
		client: client,
	}
}

func (s *BookTemplateService) ListAll(ctx context.Context, req *emptypb.Empty) (*ledgerV1.ListBookTemplateResponse, error) {
	return s.client.ListAll(ctx, req)
}

func (s *BookTemplateService) Get(ctx context.Context, req *ledgerV1.GetBookTemplateRequest) (*ledgerV1.BookTemplate, error) {
	return s.client.Get(ctx, req)
}
