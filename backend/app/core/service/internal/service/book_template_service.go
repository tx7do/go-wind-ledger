package service

import (
	"context"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

// BookTemplateService 账本模板服务（内置模板，硬编码）
type BookTemplateService struct {
	ledgerV1.UnimplementedBookTemplateServiceServer

	log *log.Helper

	templates []*ledgerV1.BookTemplate
	byID      map[uint32]*ledgerV1.BookTemplate
}

// NewBookTemplateService 创建账本模板服务。
func NewBookTemplateService(ctx *bootstrap.Context) *BookTemplateService {
	s := &BookTemplateService{
		log: ctx.NewLoggerHelper("book_template/service/core-service"),
	}
	s.templates = buildBuiltinBookTemplates()
	s.byID = make(map[uint32]*ledgerV1.BookTemplate, len(s.templates))
	for _, t := range s.templates {
		s.byID[t.GetId()] = t
	}
	return s
}

// ListAll 返回所有内置账本模板。
func (s *BookTemplateService) ListAll(ctx context.Context, req *emptypb.Empty) (*ledgerV1.ListBookTemplateResponse, error) {
	return &ledgerV1.ListBookTemplateResponse{Items: s.templates}, nil
}

// Get 按id返回单个账本模板。
func (s *BookTemplateService) Get(ctx context.Context, req *ledgerV1.GetBookTemplateRequest) (*ledgerV1.BookTemplate, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	t, ok := s.byID[req.GetId()]
	if !ok {
		return nil, ledgerV1.ErrorNotFound("book template not found")
	}
	return t, nil
}

// buildBuiltinBookTemplates 构建内置账本模板列表。
// 模板 ID 从 1 开始递增；分类模板的 type 字段使用 CategoryType 枚举名
// （与 ledgerV1.CategoryType.String() 一致，如 CATEGORY_TYPE_EXPENSE / CATEGORY_TYPE_INCOME）。
func buildBuiltinBookTemplates() []*ledgerV1.BookTemplate {
	personal := &ledgerV1.BookTemplate{
		Id:        uint32Ptr(1),
		Name:      strPtr("个人记账"),
		Locale:    strPtr("zh-CN"),
		Thumbnail: strPtr(""),
		Categories: []*ledgerV1.CategoryTemplate{
			{Name: strPtr("餐饮"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("交通"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("购物"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("住房"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("娱乐"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("医疗"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("工资"), Type: strPtr(categoryTypeNameIncome), Level: uint32Ptr(0)},
			{Name: strPtr("兼职"), Type: strPtr(categoryTypeNameIncome), Level: uint32Ptr(0)},
			{Name: strPtr("理财收益"), Type: strPtr(categoryTypeNameIncome), Level: uint32Ptr(0)},
		},
		Tags: []*ledgerV1.TagTemplate{
			{Name: strPtr("日常")},
			{Name: strPtr("必需")},
		},
		Payees: []*ledgerV1.PayeeTemplate{
			{Name: strPtr("超市")},
			{Name: strPtr("便利店")},
		},
	}

	family := &ledgerV1.BookTemplate{
		Id:        uint32Ptr(2),
		Name:      strPtr("家庭记账"),
		Locale:    strPtr("zh-CN"),
		Thumbnail: strPtr(""),
		Categories: []*ledgerV1.CategoryTemplate{
			{Name: strPtr("家庭餐饮"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("家庭交通"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("子女教育"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("家庭旅游"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("水电煤"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("家庭医疗"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("家庭工资"), Type: strPtr(categoryTypeNameIncome), Level: uint32Ptr(0)},
			{Name: strPtr("投资收益"), Type: strPtr(categoryTypeNameIncome), Level: uint32Ptr(0)},
		},
		Tags: []*ledgerV1.TagTemplate{
			{Name: strPtr("家庭")},
			{Name: strPtr("孩子")},
			{Name: strPtr("投资")},
		},
		Payees: []*ledgerV1.PayeeTemplate{
			{Name: strPtr("学校")},
			{Name: strPtr("医院")},
		},
	}

	business := &ledgerV1.BookTemplate{
		Id:        uint32Ptr(3),
		Name:      strPtr("小型商户"),
		Locale:    strPtr("zh-CN"),
		Thumbnail: strPtr(""),
		Categories: []*ledgerV1.CategoryTemplate{
			{Name: strPtr("进货成本"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("店铺租金"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("员工薪酬"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("营销推广"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("日常运营"), Type: strPtr(categoryTypeNameExpense), Level: uint32Ptr(0)},
			{Name: strPtr("商品销售"), Type: strPtr(categoryTypeNameIncome), Level: uint32Ptr(0)},
			{Name: strPtr("服务收入"), Type: strPtr(categoryTypeNameIncome), Level: uint32Ptr(0)},
		},
		Tags: []*ledgerV1.TagTemplate{
			{Name: strPtr("运营")},
			{Name: strPtr("采购")},
			{Name: strPtr("销售")},
		},
		Payees: []*ledgerV1.PayeeTemplate{
			{Name: strPtr("供应商")},
			{Name: strPtr("房东")},
		},
	}

	return []*ledgerV1.BookTemplate{personal, family, business}
}

// categoryTypeNameExpense / categoryTypeNameIncome 对应 ledgerV1.CategoryType 枚举名。
// 与 ent category.Type 的存储值一致（见 app/core/service/internal/data/ent/category/category.go）。
const (
	categoryTypeNameExpense = "CATEGORY_TYPE_EXPENSE"
	categoryTypeNameIncome  = "CATEGORY_TYPE_INCOME"
)

// parseCategoryType 将 CategoryTemplate.type 字符串解析为 ledgerV1.CategoryType。
// 支持完整枚举名（CATEGORY_TYPE_EXPENSE / CATEGORY_TYPE_INCOME）以及
// 友好别名（expense / income），默认回退到支出类型。
func parseCategoryType(typ string) ledgerV1.CategoryType {
	switch typ {
	case categoryTypeNameExpense, "expense", "EXPENSE":
		return ledgerV1.CategoryType_CATEGORY_TYPE_EXPENSE
	case categoryTypeNameIncome, "income", "INCOME":
		return ledgerV1.CategoryType_CATEGORY_TYPE_INCOME
	default:
		return ledgerV1.CategoryType_CATEGORY_TYPE_EXPENSE
	}
}

// 注：strPtr / uint32Ptr 辅助函数已在 currency_service.go 中定义，此处复用。

