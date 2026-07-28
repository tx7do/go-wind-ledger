package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	appV1 "go-wind-cms/api/gen/go/app/service/v1"
	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type FlowFileService struct {
	appV1.FlowFileServiceHTTPServer

	client ledgerV1.FlowFileServiceClient
	log    *log.Helper
}

func NewFlowFileService(ctx *bootstrap.Context, client ledgerV1.FlowFileServiceClient) *FlowFileService {
	return &FlowFileService{
		log:    ctx.NewLoggerHelper("flow-file/service/app-service"),
		client: client,
	}
}

func (s *FlowFileService) List(ctx context.Context, req *ledgerV1.ListFlowFileRequest) (*ledgerV1.ListFlowFileResponse, error) {
	return s.client.List(ctx, req)
}

func (s *FlowFileService) Delete(ctx context.Context, req *ledgerV1.DeleteFlowFileRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}
