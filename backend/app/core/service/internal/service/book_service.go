package service

import (
	"bytes"
	"context"
	"fmt"
	"strconv"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	"github.com/tx7do/go-utils/trans"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/emptypb"

	"go-wind-ledger/app/core/service/internal/data"
	"go-wind-ledger/app/core/service/internal/data/ent/balanceflow"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"

	"go-wind-ledger/pkg/middleware/auth"
)

type BookService struct {
	ledgerV1.UnimplementedBookServiceServer
	bookRepo        *data.BookRepo
	flowRepo        *data.BalanceFlowRepo
	membershipRepo  *data.MembershipRepo
	categoryRepo    *data.CategoryRepo
	tagRepo         *data.TagRepo
	payeeRepo       *data.PayeeRepo
	templateService *BookTemplateService
	log             *log.Helper
}

func NewBookService(
	ctx *bootstrap.Context,
	bookRepo *data.BookRepo,
	flowRepo *data.BalanceFlowRepo,
	membershipRepo *data.MembershipRepo,
	categoryRepo *data.CategoryRepo,
	tagRepo *data.TagRepo,
	payeeRepo *data.PayeeRepo,
	templateService *BookTemplateService,
) *BookService {
	return &BookService{
		log:             ctx.NewLoggerHelper("book/service/core-service"),
		bookRepo:        bookRepo,
		flowRepo:        flowRepo,
		membershipRepo:  membershipRepo,
		categoryRepo:    categoryRepo,
		tagRepo:         tagRepo,
		payeeRepo:       payeeRepo,
		templateService: templateService,
	}
}

func (s *BookService) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListBookResponse, error) {
	return s.bookRepo.List(ctx, req)
}

func (s *BookService) ListAll(ctx context.Context, req *ledgerV1.ListAllBookRequest) (*ledgerV1.ListBookResponse, error) {
	return s.bookRepo.ListAll(ctx, req.GetIncludeDisabled())
}

func (s *BookService) Get(ctx context.Context, req *ledgerV1.GetBookRequest) (*ledgerV1.Book, error) {
	return s.bookRepo.Get(ctx, req.GetId())
}

func (s *BookService) Create(ctx context.Context, req *ledgerV1.CreateBookRequest) (*ledgerV1.Book, error) {
	if req.Data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	return s.bookRepo.Create(ctx, req.Data)
}

func (s *BookService) Update(ctx context.Context, req *ledgerV1.UpdateBookRequest) (*ledgerV1.Book, error) {
	return s.bookRepo.Update(ctx, req.GetId(), req.Data, req.GetUpdateMask())
}

func (s *BookService) Delete(ctx context.Context, req *ledgerV1.DeleteBookRequest) (*emptypb.Empty, error) {
	if err := s.bookRepo.Delete(ctx, req.GetId()); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

func (s *BookService) Toggle(ctx context.Context, req *ledgerV1.ToggleBookRequest) (*ledgerV1.Book, error) {
	return s.bookRepo.Toggle(ctx, req.GetId())
}

// CreateByTemplate 从账本模板创建账本。
// 1. 获取模板（调用 BookTemplateService.Get）
// 2. 创建账本（调用 BookRepo.Create）
// 3. 遍历模板的 categories，创建分类（调用 CategoryRepo.Create）
// 4. 遍历模板的 tags，创建标签（调用 TagRepo.Create）
// 5. 遍历模板的 payees，创建收款人（调用 PayeeRepo.Create）
// 6. 返回创建的账本
func (s *BookService) CreateByTemplate(ctx context.Context, req *ledgerV1.CreateBookByTemplateRequest) (*ledgerV1.Book, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	if req.GetName() == "" {
		return nil, ledgerV1.ErrorBadRequest("book name is required")
	}
	if req.GetTemplateId() == 0 {
		return nil, ledgerV1.ErrorBadRequest("template id is required")
	}

	// 1. 获取模板
	tpl, err := s.templateService.Get(ctx, &ledgerV1.GetBookTemplateRequest{Id: req.GetTemplateId()})
	if err != nil {
		return nil, err
	}

	// 2. 创建账本
	bookData := &ledgerV1.Book{
		Name:                trans.Ptr(req.GetName()),
		DefaultCurrencyCode: trans.Ptr(req.GetDefaultCurrencyCode()),
		Enable:              trans.Ptr(true),
	}
	if req.Notes != nil {
		bookData.Notes = trans.Ptr(req.GetNotes())
	}
	createdBook, err := s.bookRepo.Create(ctx, bookData)
	if err != nil {
		return nil, err
	}
	newBookID := createdBook.GetId()
	if newBookID == 0 {
		return nil, ledgerV1.ErrorInternalServerError("created book has no id")
	}

	// 3. 遍历模板的 categories，创建分类（保持 level 作为 depth）
	for _, c := range tpl.GetCategories() {
		catData := &ledgerV1.Category{
			BookId: trans.Ptr(newBookID),
			Name:   trans.Ptr(c.GetName()),
			Enable: trans.Ptr(true),
		}
		typ := parseCategoryType(c.GetType())
		catData.Type = &typ
		if c.Level != nil {
			catData.Depth = trans.Ptr(int32(c.GetLevel()))
		}
		if _, err := s.categoryRepo.Create(ctx, catData); err != nil {
			s.log.Errorf("create category from template failed: %s", err.Error())
			return nil, err
		}
	}

	// 4. 遍历模板的 tags，创建标签
	for _, t := range tpl.GetTags() {
		tagData := &ledgerV1.Tag{
			BookId: trans.Ptr(newBookID),
			Name:   trans.Ptr(t.GetName()),
			Enable: trans.Ptr(true),
		}
		if _, err := s.tagRepo.Create(ctx, tagData); err != nil {
			s.log.Errorf("create tag from template failed: %s", err.Error())
			return nil, err
		}
	}

	// 5. 遍历模板的 payees，创建收款人
	for _, p := range tpl.GetPayees() {
		payeeData := &ledgerV1.Payee{
			BookId: trans.Ptr(newBookID),
			Name:   trans.Ptr(p.GetName()),
			Enable: trans.Ptr(true),
		}
		if _, err := s.payeeRepo.Create(ctx, payeeData); err != nil {
			s.log.Errorf("create payee from template failed: %s", err.Error())
			return nil, err
		}
	}

	// 6. 返回创建的账本
	return createdBook, nil
}

// Copy 复制账本。
// 1. 获取源账本（验证存在）
// 2. 创建新账本（name/notes/currencyCode 从源账本复制，name 用请求参数覆盖）
// 3. 查询源账本的所有分类，创建到新账本（保持树形结构）
// 4. 查询源账本的所有标签，创建到新账本
// 5. 查询源账本的所有收款人，创建到新账本
// 6. 返回新账本
func (s *BookService) Copy(ctx context.Context, req *ledgerV1.CopyBookRequest) (*ledgerV1.Book, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	if req.GetSourceBookId() == 0 {
		return nil, ledgerV1.ErrorBadRequest("source book id is required")
	}
	if req.GetName() == "" {
		return nil, ledgerV1.ErrorBadRequest("book name is required")
	}

	// 1. 获取源账本（验证存在）
	sourceBook, err := s.bookRepo.Get(ctx, req.GetSourceBookId())
	if err != nil {
		return nil, err
	}

	// 2. 创建新账本（currencyCode 从源账本复制，name 用请求参数，notes 优先用请求参数否则从源账本复制）
	bookData := &ledgerV1.Book{
		Name:                trans.Ptr(req.GetName()),
		DefaultCurrencyCode: trans.Ptr(sourceBook.GetDefaultCurrencyCode()),
		Enable:              trans.Ptr(true),
	}
	if req.Notes != nil {
		bookData.Notes = trans.Ptr(req.GetNotes())
	} else if sourceBook.Notes != nil {
		bookData.Notes = trans.Ptr(sourceBook.GetNotes())
	}
	createdBook, err := s.bookRepo.Create(ctx, bookData)
	if err != nil {
		return nil, err
	}
	newBookID := createdBook.GetId()
	if newBookID == 0 {
		return nil, ledgerV1.ErrorInternalServerError("created book has no id")
	}

	// 3. 查询源账本的所有分类，创建到新账本（保持树形结构）
	//    ListAll 返回该 book 下所有 enable=true 的分类（含父子），按 parent_id 重建树形关系。
	srcCats, err := s.categoryRepo.ListAll(ctx, req.GetSourceBookId(), nil)
	if err != nil {
		return nil, err
	}
	// 先按原 ID 排序创建父分类，再创建子分类；用 map 记录 oldID->newID 以重建父子关系。
	catIDMap := make(map[uint32]uint32, len(srcCats.GetItems()))
	// 按 depth 升序处理，确保父分类先于子分类创建。
	cats := sortByDepth(srcCats.GetItems())
	for _, c := range cats {
		newCat := &ledgerV1.Category{
			BookId: trans.Ptr(newBookID),
			Name:   trans.Ptr(c.GetName()),
			Enable: trans.Ptr(true),
		}
		if c.Type != nil {
			typ := c.GetType()
			newCat.Type = &typ
		}
		if c.Depth != nil {
			newCat.Depth = trans.Ptr(c.GetDepth())
		}
		if c.ParentId != nil && c.GetParentId() != 0 {
			if newParentID, ok := catIDMap[c.GetParentId()]; ok {
				newCat.ParentId = trans.Ptr(newParentID)
			}
		}
		created, err := s.categoryRepo.Create(ctx, newCat)
		if err != nil {
			s.log.Errorf("copy category failed: %s", err.Error())
			return nil, err
		}
		catIDMap[c.GetId()] = created.GetId()
	}

	// 4. 查询源账本的所有标签，创建到新账本
	srcTags, err := s.tagRepo.ListAll(ctx, req.GetSourceBookId())
	if err != nil {
		return nil, err
	}
	tagIDMap := make(map[uint32]uint32, len(srcTags.GetItems()))
	// 标签亦支持树形（parent_id），按 depth 升序重建父子关系。
	tags := sortByDepthGeneric(srcTags.GetItems(), func(t *ledgerV1.Tag) int32 {
		return t.GetDepth()
	}, func(t *ledgerV1.Tag) uint32 {
		return t.GetId()
	}, func(t *ledgerV1.Tag) uint32 {
		return t.GetParentId()
	})
	for _, t := range tags {
		newTag := &ledgerV1.Tag{
			BookId:      trans.Ptr(newBookID),
			Name:        trans.Ptr(t.GetName()),
			Enable:      trans.Ptr(true),
			CanExpense:  t.CanExpense,
			CanIncome:   t.CanIncome,
			CanTransfer: t.CanTransfer,
		}
		if t.Depth != nil {
			newTag.Depth = trans.Ptr(t.GetDepth())
		}
		if t.ParentId != nil && t.GetParentId() != 0 {
			if newParentID, ok := tagIDMap[t.GetParentId()]; ok {
				newTag.ParentId = trans.Ptr(newParentID)
			}
		}
		created, err := s.tagRepo.Create(ctx, newTag)
		if err != nil {
			s.log.Errorf("copy tag failed: %s", err.Error())
			return nil, err
		}
		tagIDMap[t.GetId()] = created.GetId()
	}

	// 5. 查询源账本的所有收款人，创建到新账本
	srcPayees, err := s.payeeRepo.ListAll(ctx, req.GetSourceBookId())
	if err != nil {
		return nil, err
	}
	for _, p := range srcPayees.GetItems() {
		newPayee := &ledgerV1.Payee{
			BookId:     trans.Ptr(newBookID),
			Name:       trans.Ptr(p.GetName()),
			Enable:     trans.Ptr(true),
			CanExpense: p.CanExpense,
			CanIncome:  p.CanIncome,
		}
		if _, err := s.payeeRepo.Create(ctx, newPayee); err != nil {
			s.log.Errorf("copy payee failed: %s", err.Error())
			return nil, err
		}
	}

	// 6. 返回新账本
	return createdBook, nil
}

// sortByDepth 按 depth 升序稳定排序分类，确保父分类先于子分类创建。
func sortByDepth(items []*ledgerV1.Category) []*ledgerV1.Category {
	out := make([]*ledgerV1.Category, len(items))
	copy(out, items)
	for i := 1; i < len(out); i++ {
		for j := i; j > 0 && out[j].GetDepth() < out[j-1].GetDepth(); j-- {
			out[j], out[j-1] = out[j-1], out[j]
		}
	}
	return out
}

// sortByDepthGeneric 通用稳定排序：按 depth 升序排列任意带 depth/parentId/id 的元素。
func sortByDepthGeneric[T any](items []T, depth func(T) int32, id func(T) uint32, parentID func(T) uint32) []T {
	out := make([]T, len(items))
	copy(out, items)
	for i := 1; i < len(out); i++ {
		for j := i; j > 0 && depth(out[j]) < depth(out[j-1]); j-- {
			out[j], out[j-1] = out[j-1], out[j]
		}
	}
	return out
}

// Export 导出账本流水为 CSV。
// 查询账本所有流水（按 createTime 升序），生成 CSV 字节，返回 ExportBookResponse。
func (s *BookService) Export(ctx context.Context, req *ledgerV1.ExportBookRequest) (*ledgerV1.ExportBookResponse, error) {
	if req == nil || req.GetId() == 0 {
		return nil, ledgerV1.ErrorBadRequest("invalid book id")
	}
	bookID := req.GetId()
	timeZoneOffset := req.GetTimeZoneOffset()

	// 1. 获取账本信息（用于文件名）
	bookInfo, err := s.bookRepo.Get(ctx, bookID)
	if err != nil {
		return nil, err
	}

	// 2. 查询账本所有流水（按 createTime 升序）
	flows, err := s.flowRepo.QueryFlowsByBook(ctx, bookID)
	if err != nil {
		s.log.Errorf("query flows by book failed: %s", err.Error())
		return nil, ledgerV1.ErrorInternalServerError("query flows failed")
	}

	// 3. 预加载账户与收款人名称映射（用于 CSV 渲染）
	accountNames := make(map[uint32]string)
	if accounts, err := s.flowRepo.QueryEnabledAccounts(ctx); err == nil {
		for _, a := range accounts {
			if a.Name != nil {
				accountNames[a.ID] = *a.Name
			}
		}
	}
	payeeNames := make(map[uint32]string)
	if payees, err := s.flowRepo.QueryAllPayees(ctx); err == nil {
		for _, p := range payees {
			if p.Name != nil {
				payeeNames[p.ID] = *p.Name
			}
		}
	}

	// 4. 生成 CSV
	var buf bytes.Buffer
	// UTF-8 BOM，便于 Excel 正确识别编码
	buf.Write([]byte{0xEF, 0xBB, 0xBF})
	buf.WriteString("日期,类型,标题,金额,换算金额,账户,收款人,备注\n")

	for _, f := range flows {
		date := formatFlowTime(f.CreateTime, timeZoneOffset)
		flowType := flowTypeDisplay(f.Type)
		title := safeStr(f.Title)
		amount := formatEntAmount(f.Amount)
		convertedAmount := formatEntAmount(f.ConvertedAmount)
		accountName := nameById(accountNames, f.AccountID)
		toAccountName := nameById(accountNames, f.ToAccountID)
		accountCell := accountName
		if f.Type != nil && *f.Type == balanceflow.TypeFlowTypeTransfer && toAccountName != "" {
			accountCell = accountName + " -> " + toAccountName
		}
		payeeName := nameById(payeeNames, f.PayeeID)
		notes := safeStr(f.Notes)

		buf.WriteString(csvField(date))
		buf.WriteString(",")
		buf.WriteString(csvField(flowType))
		buf.WriteString(",")
		buf.WriteString(csvField(title))
		buf.WriteString(",")
		buf.WriteString(csvField(amount))
		buf.WriteString(",")
		buf.WriteString(csvField(convertedAmount))
		buf.WriteString(",")
		buf.WriteString(csvField(accountCell))
		buf.WriteString(",")
		buf.WriteString(csvField(payeeName))
		buf.WriteString(",")
		buf.WriteString(csvField(notes))
		buf.WriteString("\n")
	}

	bookName := bookInfo.GetName()
	if bookName == "" {
		bookName = "book"
	}
	fileName := fmt.Sprintf("%s_export.csv", bookName)

	return &ledgerV1.ExportBookResponse{
		FileName:    fileName,
		ContentType: "text/csv",
		Data:        buf.Bytes(),
	}, nil
}

// ListAllBooks 跨租户账本列表（bookSelect）。
// 从 auth context 获取当前用户 ID，查询其所有 membership 得到可访问租户，
// 再查询这些租户下所有 enable=true 的账本。
func (s *BookService) ListAllBooks(ctx context.Context, req *emptypb.Empty) (*ledgerV1.ListBookResponse, error) {
	operator, err := auth.FromContext(ctx)
	if err != nil {
		return nil, err
	}
	userID := operator.GetUserId()
	if userID == 0 {
		return nil, ledgerV1.ErrorBadRequest("invalid user id")
	}

	// 1. 查询用户所有 membership
	memberships, err := s.membershipRepo.FindByUser(ctx, userID)
	if err != nil {
		s.log.Errorf("find membership by user failed: %s", err.Error())
		return nil, ledgerV1.ErrorInternalServerError("find membership failed")
	}

	// 2. 收集所有租户 ID
	tenantIDs := make([]uint32, 0, len(memberships))
	for _, m := range memberships {
		if m.GetTenantId() > 0 {
			tenantIDs = append(tenantIDs, m.GetTenantId())
		}
	}
	if len(tenantIDs) == 0 {
		return &ledgerV1.ListBookResponse{Items: []*ledgerV1.Book{}, Total: 0}, nil
	}

	// 3. 查询这些租户下所有 enable=true 的账本
	return s.bookRepo.ListByTenants(ctx, tenantIDs)
}

// formatFlowTime 将 epoch 毫秒渲染为本地时间字符串（按 timeZoneOffset 分钟数偏移）。
func formatFlowTime(createTime *int64, timeZoneOffset int32) string {
	if createTime == nil || *createTime == 0 {
		return ""
	}
	t := time.UnixMilli(*createTime)
	if timeZoneOffset != 0 {
		t = t.Add(time.Duration(timeZoneOffset) * time.Minute)
	}
	return t.Format("2006-01-02 15:04:05")
}

// flowTypeDisplay 将 ent 流水类型枚举转换为中文展示文本。
func flowTypeDisplay(t *balanceflow.Type) string {
	if t == nil {
		return ""
	}
	switch *t {
	case balanceflow.TypeFlowTypeExpense:
		return "支出"
	case balanceflow.TypeFlowTypeIncome:
		return "收入"
	case balanceflow.TypeFlowTypeTransfer:
		return "转账"
	case balanceflow.TypeFlowTypeAdjust:
		return "余额调整"
	}
	return ""
}

// formatEntAmount 将 *float64 渲染为两位小数字符串。
func formatEntAmount(v *float64) string {
	if v == nil {
		return "0.00"
	}
	return strconv.FormatFloat(*v, 'f', 2, 64)
}

// safeStr 安全解引用字符串指针。
func safeStr(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

// nameById 按账户/收款人 ID 查找名称（找不到返回空串）。
func nameById(names map[uint32]string, id *uint32) string {
	if id == nil {
		return ""
	}
	return names[*id]
}

// csvField 对 CSV 字段进行转义：包含逗号、引号或换行时用双引号包裹并把内部引号翻倍。
func csvField(s string) string {
	if s == "" {
		return ""
	}
	needQuote := false
	for i := 0; i < len(s); i++ {
		switch s[i] {
		case ',', '"', '\n', '\r':
			needQuote = true
		}
		if needQuote {
			break
		}
	}
	if !needQuote {
		return s
	}
	// 引号翻倍并用双引号包裹
	buf := make([]byte, 0, len(s)+2)
	buf = append(buf, '"')
	for i := 0; i < len(s); i++ {
		if s[i] == '"' {
			buf = append(buf, '"')
		}
		buf = append(buf, s[i])
	}
	buf = append(buf, '"')
	return string(buf)
}
