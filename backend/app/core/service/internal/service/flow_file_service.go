package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	"go-wind-ledger/app/core/service/internal/data"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"

	"go-wind-ledger/pkg/middleware/auth"
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

// UploadFile 上传流水附件。creator_id 取自认证上下文，由 repo 落库。
func (s *FlowFileService) UploadFile(ctx context.Context, req *ledgerV1.UploadFlowFileRequest) (*ledgerV1.FlowFile, error) {
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}
	creatorID := operator.GetUserId()
	if creatorID == 0 {
		return nil, ledgerV1.ErrorBadRequest("invalid creator")
	}
	return s.flowFileRepo.UploadFile(ctx, creatorID, req)
}

// ViewFile 查看流水附件（免认证，按 create_time 安全校验）。
func (s *FlowFileService) ViewFile(ctx context.Context, req *ledgerV1.ViewFlowFileRequest) (*ledgerV1.ViewFlowFileResponse, error) {
	return s.flowFileRepo.ViewFile(ctx, req)
}
