package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	adminV1 "go-wind-ledger/api/gen/go/admin/service/v1"
	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

type FlowFileService struct {
	adminV1.FlowFileServiceHTTPServer
	client ledgerV1.FlowFileServiceClient
	log    *log.Helper
}

func NewFlowFileService(ctx *bootstrap.Context, client ledgerV1.FlowFileServiceClient) *FlowFileService {
	return &FlowFileService{
		log:    ctx.NewLoggerHelper("flowfile/service/admin-service"),
		client: client,
	}
}

func (s *FlowFileService) List(ctx context.Context, req *ledgerV1.ListFlowFileRequest) (*ledgerV1.ListFlowFileResponse, error) {
	return s.client.List(ctx, req)
}

func (s *FlowFileService) Delete(ctx context.Context, req *ledgerV1.DeleteFlowFileRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}

func (s *FlowFileService) UploadFile(ctx context.Context, req *ledgerV1.UploadFlowFileRequest) (*ledgerV1.FlowFile, error) {
	return s.client.UploadFile(ctx, req)
}

func (s *FlowFileService) ViewFile(ctx context.Context, req *ledgerV1.ViewFlowFileRequest) (*ledgerV1.ViewFlowFileResponse, error) {
	return s.client.ViewFile(ctx, req)
}
