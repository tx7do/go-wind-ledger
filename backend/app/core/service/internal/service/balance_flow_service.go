package service

import (
	"context"
	"fmt"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	"go-wind-cms/app/core/service/internal/data"
	"go-wind-cms/app/core/service/internal/data/ent"

	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type BalanceFlowService struct {
	ledgerV1.UnimplementedBalanceFlowServiceServer
	flowRepo     *data.BalanceFlowRepo
	flowFileRepo *data.FlowFileRepo
	log          *log.Helper
}

func NewBalanceFlowService(ctx *bootstrap.Context, flowRepo *data.BalanceFlowRepo, flowFileRepo *data.FlowFileRepo) *BalanceFlowService {
	return &BalanceFlowService{
		log:          ctx.NewLoggerHelper("balanceflow/service/core-service"),
		flowRepo:     flowRepo,
		flowFileRepo: flowFileRepo,
	}
}

func (s *BalanceFlowService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListBalanceFlowResponse, error) {
	return s.flowRepo.List(ctx, req)
}

func (s *BalanceFlowService) Get(ctx context.Context, req *ledgerV1.GetBalanceFlowRequest) (*ledgerV1.BalanceFlow, error) {
	return s.flowRepo.Get(ctx, req.GetId())
}

// Create handles the full flow creation logic:
// - Validates by type (categories required for expense/income, to account for transfer)
// - Sums category amounts to total
// - Creates category/tag relations
// - Confirms balance if confirm=true
func (s *BalanceFlowService) Create(ctx context.Context, req *ledgerV1.CreateBalanceFlowRequest) (*ledgerV1.BalanceFlow, error) {
	if req.Data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	d := req.Data
	if d.GetType() == ledgerV1.FlowType_FLOW_TYPE_UNSPECIFIED {
		return nil, ledgerV1.ErrorBadRequest("flow type is required")
	}

	// Validate by type
	switch d.GetType() {
	case ledgerV1.FlowType_FLOW_TYPE_EXPENSE, ledgerV1.FlowType_FLOW_TYPE_INCOME:
		if len(d.Categories) == 0 {
			return nil, ledgerV1.ErrorBadRequest("categories are required for expense/income")
		}
		if len(d.Categories) > 10 {
			return nil, ledgerV1.ErrorBadRequest("max 10 categories per flow")
		}
		// Check for duplicate category IDs
		seen := make(map[uint32]bool)
		for _, cat := range d.Categories {
			if seen[cat.GetCategoryId()] {
				return nil, ledgerV1.ErrorBadRequest("duplicate category in flow")
			}
			seen[cat.GetCategoryId()] = true
		}
		// Sum category amounts
		var total float64
		var totalConverted float64
		for _, cat := range d.Categories {
			total += data.StrToFloat(cat.GetAmount())
			totalConverted += data.StrToFloat(cat.GetConvertedAmount())
		}
		totalStr := data.FloatToStr(total)
		totalConvStr := data.FloatToStr(totalConverted)
		if d.Amount == nil || *d.Amount == "" || *d.Amount == "0" {
			d.Amount = &totalStr
		}
		if d.ConvertedAmount == nil || *d.ConvertedAmount == "" || *d.ConvertedAmount == "0" {
			d.ConvertedAmount = &totalConvStr
		}
	case ledgerV1.FlowType_FLOW_TYPE_TRANSFER:
		if d.GetAccountId() == 0 || d.GetToAccountId() == 0 {
			return nil, ledgerV1.ErrorBadRequest("source and target accounts required for transfer")
		}
	case ledgerV1.FlowType_FLOW_TYPE_ADJUST:
		// ADJUST is created by account balance adjustment, not directly
	}
	if d.CreateTime == nil || *d.CreateTime == 0 {
		now := time.Now().UnixMilli()
		d.CreateTime = &now
	}

	// Create the flow
	saved, err := s.flowRepo.CreateFlow(ctx, d)
	if err != nil {
		return nil, err
	}

	// Create category relations
	if len(d.Categories) > 0 {
		items := make([]*data.CategoryRelationItem, 0, len(d.Categories))
		for _, c := range d.Categories {
			amount := data.StrToFloat(c.GetAmount())
			item := &data.CategoryRelationItem{
				CategoryID: c.GetCategoryId(),
				Amount:     amount,
			}
			if c.ConvertedAmount != nil {
				v := data.StrToFloat(c.GetConvertedAmount())
				item.ConvertedAmount = &v
			}
			items = append(items, item)
		}
		if err := s.flowRepo.CreateCategoryRelations(ctx, saved.GetId(), items); err != nil {
			return nil, ledgerV1.ErrorInternalServerError("create category relations failed")
		}
	}

	// Create tag relations
	if len(d.Tags) > 0 {
		items := make([]*data.TagRelationItem, 0, len(d.Tags))
		for _, t := range d.Tags {
			amount := data.StrToFloat(t.GetAmount())
			item := &data.TagRelationItem{
				TagID:  t.GetTagId(),
				Amount: amount,
			}
			if t.ConvertedAmount != nil {
				v := data.StrToFloat(t.GetConvertedAmount())
				item.ConvertedAmount = &v
			}
			items = append(items, item)
		}
		if err := s.flowRepo.CreateTagRelations(ctx, saved.GetId(), items); err != nil {
			return nil, ledgerV1.ErrorInternalServerError("create tag relations failed")
		}
	}

	// Confirm balance if requested
	if d.GetConfirm() {
		if err := s.flowRepo.ConfirmBalance(ctx, saved); err != nil {
			return nil, ledgerV1.ErrorInternalServerError("confirm balance failed")
		}
	}

	return s.flowRepo.Get(ctx, saved.GetId())
}

// Update implements the copy-then-delete pattern (Java: BalanceFlowService.update).
// Locks book/type/confirm from old flow, creates new, migrates files, deletes old.
func (s *BalanceFlowService) Update(ctx context.Context, req *ledgerV1.UpdateBalanceFlowRequest) (*ledgerV1.BalanceFlow, error) {
	oldFlow, err := s.flowRepo.Get(ctx, req.GetId())
	if err != nil {
		return nil, err
	}

	// Lock book, type, confirm from old flow
	req.Data.BookId = oldFlow.BookId
	req.Data.Type = oldFlow.Type
	req.Data.Confirm = oldFlow.Confirm

	// Delete old category/tag relations
	_ = s.flowRepo.DeleteCategoryRelationsByFlow(ctx, req.GetId())
	_ = s.flowRepo.DeleteTagRelationsByFlow(ctx, req.GetId())

	// Create new flow (this will also create new relations)
	createReq := &ledgerV1.CreateBalanceFlowRequest{Data: req.Data}
	newFlow, err := s.Create(ctx, createReq)
	if err != nil {
		return nil, err
	}

	// Migrate attachments from old flow to new flow
	if err := s.flowFileRepo.ReassignFlow(ctx, req.GetId(), newFlow.GetId()); err != nil {
		s.log.Warnf("failed to migrate attachments from flow %d to %d: %s", req.GetId(), newFlow.GetId(), err.Error())
	}

	// Delete old flow (refund balance first if confirmed)
	if oldFlow.GetConfirm() {
		entFlow, _ := s.oGetEntity(ctx, req.GetId())
		if entFlow != nil {
			if err := s.flowRepo.RefundBalance(ctx, entFlow); err != nil {
				s.log.Errorf("refundBalance failed for old flow %d: %s", req.GetId(), err.Error())
				return nil, ledgerV1.ErrorInternalServerError("refund balance failed")
			}
		}
	}
	_ = s.flowRepo.Delete(ctx, req.GetId())

	return newFlow, nil
}

func (s *BalanceFlowService) Delete(ctx context.Context, req *ledgerV1.DeleteBalanceFlowRequest) (*emptypb.Empty, error) {
	id := req.GetId()

	// Get the flow to check confirm status
	flow, err := s.flowRepo.Get(ctx, id)
	if err != nil {
		return nil, err
	}

	// Refund balance if confirmed
	if flow.GetConfirm() {
		entFlow, _ := s.oGetEntity(ctx, id)
		if entFlow != nil {
			if err := s.flowRepo.RefundBalance(ctx, entFlow); err != nil {
				s.log.Errorf("refund balance failed for flow id=%d: %s", id, err.Error())
				return nil, ledgerV1.ErrorInternalServerError("refund balance failed, cannot delete flow")
			}
		}
	}

	// Clean up relations
	_ = s.flowRepo.DeleteCategoryRelationsByFlow(ctx, id)
	_ = s.flowRepo.DeleteTagRelationsByFlow(ctx, id)

	if err := s.flowRepo.Delete(ctx, id); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

// Confirm sets confirm=true and updates account balances.
func (s *BalanceFlowService) Confirm(ctx context.Context, req *ledgerV1.ConfirmBalanceFlowRequest) (*ledgerV1.BalanceFlow, error) {
	id := req.GetId()
	flow, err := s.flowRepo.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	if flow.GetConfirm() {
		return flow, nil // already confirmed
	}

	// Set confirm=true and persist to DB
	confirmTrue := true
	flow.Confirm = &confirmTrue
	confirmMask := &fieldmaskpb.FieldMask{Paths: []string{"confirm"}}
	if _, err := s.flowRepo.Update(ctx, id, flow, confirmMask); err != nil {
		return nil, ledgerV1.ErrorInternalServerError("persist confirm flag failed")
	}

	// Confirm balance (update account balances)
	if err := s.flowRepo.ConfirmBalance(ctx, flow); err != nil {
		return nil, ledgerV1.ErrorInternalServerError("confirm balance failed")
	}

	return s.flowRepo.Get(ctx, id)
}

func (s *BalanceFlowService) Statistics(ctx context.Context, req *ledgerV1.StatisticsRequest) (*ledgerV1.StatisticsResponse, error) {
	expense, income, net, err := s.flowRepo.Statistics(ctx, req.GetBookId(), req.GetConfirm())
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("statistics failed")
	}
	expenseStr := formatMoney(expense)
	incomeStr := formatMoney(income)
	netStr := formatMoney(net)
	return &ledgerV1.StatisticsResponse{
		Expense: expenseStr,
		Income:  incomeStr,
		Net:     netStr,
	}, nil
}

// oGetEntity gets raw ent entity (for refundBalance)
func (s *BalanceFlowService) oGetEntity(ctx context.Context, id uint32) (*ent.BalanceFlow, error) {
	return s.flowRepo.GetRawEntity(ctx, id)
}

func formatMoney(v float64) string {
	return fmt.Sprintf("%.2f", v)
}
