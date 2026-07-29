package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	appV1 "go-wind-ledger/api/gen/go/app/service/v1"
	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

type NoteDayService struct {
	appV1.NoteDayServiceHTTPServer

	client ledgerV1.NoteDayServiceClient
	log    *log.Helper
}

func NewNoteDayService(ctx *bootstrap.Context, client ledgerV1.NoteDayServiceClient) *NoteDayService {
	return &NoteDayService{
		log:    ctx.NewLoggerHelper("note-day/service/app-service"),
		client: client,
	}
}

func (s *NoteDayService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListNoteDayResponse, error) {
	return s.client.List(ctx, req)
}

func (s *NoteDayService) Get(ctx context.Context, req *ledgerV1.GetNoteDayRequest) (*ledgerV1.NoteDay, error) {
	return s.client.Get(ctx, req)
}

func (s *NoteDayService) Create(ctx context.Context, req *ledgerV1.CreateNoteDayRequest) (*ledgerV1.NoteDay, error) {
	return s.client.Create(ctx, req)
}

func (s *NoteDayService) Update(ctx context.Context, req *ledgerV1.UpdateNoteDayRequest) (*ledgerV1.NoteDay, error) {
	return s.client.Update(ctx, req)
}

func (s *NoteDayService) Delete(ctx context.Context, req *ledgerV1.DeleteNoteDayRequest) (*emptypb.Empty, error) {
	return s.client.Delete(ctx, req)
}

func (s *NoteDayService) Run(ctx context.Context, req *ledgerV1.RunNoteDayRequest) (*ledgerV1.NoteDay, error) {
	return s.client.Run(ctx, req)
}

func (s *NoteDayService) Recall(ctx context.Context, req *ledgerV1.RecallNoteDayRequest) (*ledgerV1.NoteDay, error) {
	return s.client.Recall(ctx, req)
}
