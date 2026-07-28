package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	"go-wind-cms/app/core/service/internal/data"

	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type FlowFileService struct {
	ledgerV1.UnimplementedFlowFileServiceServer
	flowFileRepo *data.FlowFileRepo
	log          *log.Helper
}

func NewFlowFileService(ctx *bootstrap.Context, flowFileRepo *data.FlowFileRepo) *FlowFileService {
	return &FlowFileService{
		log:          ctx.NewLoggerHelper("flowfile/service/core-service"),
		flowFileRepo: flowFileRepo,
	}
}

func (s *FlowFileService) List(ctx context.Context, req *ledgerV1.ListFlowFileRequest) (*ledgerV1.ListFlowFileResponse, error) {
	items, err := s.flowFileRepo.ListByFlow(ctx, req.GetFlowId())
	if err != nil {
		return nil, err
	}
	return &ledgerV1.ListFlowFileResponse{Items: items}, nil
}

func (s *FlowFileService) Delete(ctx context.Context, req *ledgerV1.DeleteFlowFileRequest) (*emptypb.Empty, error) {
	if err := s.flowFileRepo.Delete(ctx, req.GetId()); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}
