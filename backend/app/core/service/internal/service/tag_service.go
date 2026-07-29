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

type TagService struct {
	ledgerV1.UnimplementedTagServiceServer
	tagRepo *data.TagRepo
	log     *log.Helper
}

func NewTagService(ctx *bootstrap.Context, tagRepo *data.TagRepo) *TagService {
	return &TagService{
		log:     ctx.NewLoggerHelper("tag/service/core-service"),
		tagRepo: tagRepo,
	}
}

func (s *TagService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListTagResponse, error) {
	return s.tagRepo.List(ctx, req)
}

func (s *TagService) ListAll(ctx context.Context, req *ledgerV1.ListAllTagRequest) (*ledgerV1.ListTagResponse, error) {
	return s.tagRepo.ListAll(ctx, req.GetBookId())
}

func (s *TagService) Get(ctx context.Context, req *ledgerV1.GetTagRequest) (*ledgerV1.Tag, error) {
	return s.tagRepo.Get(ctx, req.GetId())
}

func (s *TagService) Create(ctx context.Context, req *ledgerV1.CreateTagRequest) (*ledgerV1.Tag, error) {
	if req.Data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	return s.tagRepo.Create(ctx, req.Data)
}

func (s *TagService) Update(ctx context.Context, req *ledgerV1.UpdateTagRequest) (*ledgerV1.Tag, error) {
	return s.tagRepo.Update(ctx, req.GetId(), req.Data, req.GetUpdateMask())
}

func (s *TagService) Delete(ctx context.Context, req *ledgerV1.DeleteTagRequest) (*emptypb.Empty, error) {
	if err := s.tagRepo.Delete(ctx, req.GetId()); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

func (s *TagService) Toggle(ctx context.Context, req *ledgerV1.ToggleTagRequest) (*ledgerV1.Tag, error) {
	return s.tagRepo.Toggle(ctx, req.GetId())
}

func (s *TagService) ToggleCanExpense(ctx context.Context, req *ledgerV1.ToggleTagRequest) (*ledgerV1.Tag, error) {
	return s.tagRepo.ToggleCanExpense(ctx, req.GetId())
}

func (s *TagService) ToggleCanIncome(ctx context.Context, req *ledgerV1.ToggleTagRequest) (*ledgerV1.Tag, error) {
	return s.tagRepo.ToggleCanIncome(ctx, req.GetId())
}

func (s *TagService) ToggleCanTransfer(ctx context.Context, req *ledgerV1.ToggleTagRequest) (*ledgerV1.Tag, error) {
	return s.tagRepo.ToggleCanTransfer(ctx, req.GetId())
}
