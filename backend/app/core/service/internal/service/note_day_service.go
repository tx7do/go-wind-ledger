package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	"go-wind-cms/app/core/service/internal/data"

	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type NoteDayService struct {
	ledgerV1.UnimplementedNoteDayServiceServer
	noteDayRepo *data.NoteDayRepo
	log         *log.Helper
}

func NewNoteDayService(ctx *bootstrap.Context, noteDayRepo *data.NoteDayRepo) *NoteDayService {
	return &NoteDayService{
		log:         ctx.NewLoggerHelper("noteday/service/core-service"),
		noteDayRepo: noteDayRepo,
	}
}

func (s *NoteDayService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListNoteDayResponse, error) {
	return s.noteDayRepo.List(ctx, req)
}

func (s *NoteDayService) Get(ctx context.Context, req *ledgerV1.GetNoteDayRequest) (*ledgerV1.NoteDay, error) {
	return s.noteDayRepo.Get(ctx, req.GetId())
}

func (s *NoteDayService) Create(ctx context.Context, req *ledgerV1.CreateNoteDayRequest) (*ledgerV1.NoteDay, error) {
	if req.Data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	// Calculate totalCount based on date range and interval
	d := req.Data
	if d.RepeatType != nil && d.StartDate != nil {
		repeatType := d.GetRepeatType()
		if repeatType == 0 { // Once
			val := int32(1)
			d.TotalCount = &val
			d.EndDate = d.StartDate
			d.NextDate = d.StartDate
		} else if d.EndDate != nil && d.Interval != nil {
			interval := d.GetInterval()
			if interval < 1 {
				interval = 1
			}
			var count int32
			diffMs := d.GetEndDate() - d.GetStartDate()
			diffDays := diffMs / (24 * 3600 * 1000)
			switch repeatType {
			case 1: // Daily
				count = int32(diffDays)/interval + 1
			case 2: // Monthly
				count = int32(diffDays/30)/interval + 1
			case 3: // Yearly
				count = int32(diffDays/365)/interval + 1
			}
			d.TotalCount = &count
			d.NextDate = d.StartDate
		}
	}
	return s.noteDayRepo.Create(ctx, req.Data)
}

func (s *NoteDayService) Update(ctx context.Context, req *ledgerV1.UpdateNoteDayRequest) (*ledgerV1.NoteDay, error) {
	return s.noteDayRepo.Update(ctx, req.GetId(), req.Data, req.GetUpdateMask())
}

func (s *NoteDayService) Delete(ctx context.Context, req *ledgerV1.DeleteNoteDayRequest) (*emptypb.Empty, error) {
	if err := s.noteDayRepo.Delete(ctx, req.GetId()); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

// Run advances nextDate by interval and increments runCount.
func (s *NoteDayService) Run(ctx context.Context, req *ledgerV1.RunNoteDayRequest) (*ledgerV1.NoteDay, error) {
	nd, err := s.noteDayRepo.Get(ctx, req.GetId())
	if err != nil {
		return nil, err
	}
	repeatType := nd.GetRepeatType()
	interval := nd.GetInterval()
	if interval < 1 {
		interval = 1
	}

	var nextDate int64
	switch repeatType {
	case 1: // Daily
		nextDate = nd.GetNextDate() + int64(interval)*24*3600*1000
	case 2: // Monthly
		nextDate = nd.GetNextDate() + int64(interval)*30*24*3600*1000
	case 3: // Yearly
		nextDate = nd.GetNextDate() + int64(interval)*365*24*3600*1000
	}

	runCount := nd.GetRunCount() + 1
	if err := s.noteDayRepo.UpdateNextDate(ctx, req.GetId(), nextDate, runCount); err != nil {
		return nil, ledgerV1.ErrorInternalServerError("update next date failed")
	}
	return s.noteDayRepo.Get(ctx, req.GetId())
}

// Recall reverses the Run operation.
func (s *NoteDayService) Recall(ctx context.Context, req *ledgerV1.RecallNoteDayRequest) (*ledgerV1.NoteDay, error) {
	nd, err := s.noteDayRepo.Get(ctx, req.GetId())
	if err != nil {
		return nil, err
	}
	if nd.GetRunCount() <= 0 {
		return nil, ledgerV1.ErrorBadRequest("no runs to recall")
	}
	repeatType := nd.GetRepeatType()
	interval := nd.GetInterval()
	if interval < 1 {
		interval = 1
	}

	var nextDate int64
	switch repeatType {
	case 1:
		nextDate = nd.GetNextDate() - int64(interval)*24*3600*1000
	case 2:
		nextDate = nd.GetNextDate() - int64(interval)*30*24*3600*1000
	case 3:
		nextDate = nd.GetNextDate() - int64(interval)*365*24*3600*1000
	}

	runCount := nd.GetRunCount() - 1
	if err := s.noteDayRepo.UpdateNextDate(ctx, req.GetId(), nextDate, runCount); err != nil {
		return nil, ledgerV1.ErrorInternalServerError("update next date failed")
	}
	return s.noteDayRepo.Get(ctx, req.GetId())
}
