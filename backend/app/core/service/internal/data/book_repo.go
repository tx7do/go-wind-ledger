package data

import (
	"context"
	"time"

	"entgo.io/ent/dialect/sql"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/copierutil"
	"github.com/tx7do/go-utils/mapper"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	"go-wind-cms/app/core/service/internal/data/ent"
	"go-wind-cms/app/core/service/internal/data/ent/book"
	"go-wind-cms/app/core/service/internal/data/ent/predicate"

	ledgerV1 "go-wind-cms/api/gen/go/ledger/service/v1"
)

type BookRepo struct {
	entClient  *entCrud.EntClient[*ent.Client]
	log        *log.Helper
	mapper     *mapper.CopierMapper[ledgerV1.Book, ent.Book]
	repository *entCrud.Repository[
		ent.BookQuery, ent.BookSelect,
		ent.BookCreate, ent.BookCreateBulk,
		ent.BookUpdate, ent.BookUpdateOne,
		ent.BookDelete,
		predicate.Book,
		ledgerV1.Book, ent.Book,
	]
}

func NewBookRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *BookRepo {
	repo := &BookRepo{
		log:       ctx.NewLoggerHelper("book/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[ledgerV1.Book, ent.Book](),
	}
	repo.init()
	return repo
}

func (r *BookRepo) init() {
	r.repository = entCrud.NewRepository[
		ent.BookQuery, ent.BookSelect,
		ent.BookCreate, ent.BookCreateBulk,
		ent.BookUpdate, ent.BookUpdateOne,
		ent.BookDelete,
		predicate.Book,
		ledgerV1.Book, ent.Book,
	](r.mapper)
	r.mapper.AppendConverters(copierutil.NewTimeStringConverterPair())
	r.mapper.AppendConverters(copierutil.NewTimeTimestamppbConverterPair())
}

func (r *BookRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListBookResponse, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Book.Query()
	ret, err := r.repository.ListWithPaging(ctx, builder, builder.Clone(), req)
	if err != nil {
		return nil, err
	}
	if ret == nil {
		return &ledgerV1.ListBookResponse{Total: 0}, nil
	}
	return &ledgerV1.ListBookResponse{Total: ret.Total, Items: ret.Items}, nil
}

func (r *BookRepo) ListAll(ctx context.Context, includeDisabled bool) (*ledgerV1.ListBookResponse, error) {
	q := r.entClient.Client().Book.Query()
	if !includeDisabled {
		q = q.Where(book.EnableEQ(true))
	}
	entities, err := q.All(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query books failed")
	}
	items := make([]*ledgerV1.Book, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &ledgerV1.ListBookResponse{Items: items, Total: uint64(len(items))}, nil
}

func (r *BookRepo) Get(ctx context.Context, id uint32) (*ledgerV1.Book, error) {
	entity, err := r.entClient.Client().Book.Query().Where(book.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("book not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get book failed")
	}
	return r.mapper.ToDTO(entity), nil
}

func (r *BookRepo) Create(ctx context.Context, data *ledgerV1.Book) (*ledgerV1.Book, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	tx, err := r.entClient.Client().Tx(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("start transaction failed")
	}
	defer func() {
		if err != nil {
			tx.Rollback()
			return
		}
		if commitErr := tx.Commit(); commitErr != nil {
			err = ledgerV1.ErrorInternalServerError("commit failed")
		}
	}()

	builder := tx.Book.Create().
		SetNillableName(data.Name).
		SetNillableDefaultCurrencyCode(data.DefaultCurrencyCode).
		SetNillableNotes(data.Notes).
		SetNillableEnable(data.Enable).
		SetNillableExportAt(data.ExportAt).
		SetNillableDefaultExpenseAccountID(data.DefaultExpenseAccountId).
		SetNillableDefaultIncomeAccountID(data.DefaultIncomeAccountId).
		SetNillableDefaultTransferFromAccountID(data.DefaultTransferFromAccountId).
		SetNillableDefaultTransferToAccountID(data.DefaultTransferToAccountId).
		SetNillableDefaultExpenseCategoryID(data.DefaultExpenseCategoryId).
		SetNillableDefaultIncomeCategoryID(data.DefaultIncomeCategoryId).
		SetNillableCreatedBy(data.CreatedBy).
		SetCreatedAt(time.Now())

	saved, e := builder.Save(ctx)
	if e != nil {
		err = e
		return nil, ledgerV1.ErrorInternalServerError("create book failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *BookRepo) Update(ctx context.Context, id uint32, data *ledgerV1.Book, mask *fieldmaskpb.FieldMask) (*ledgerV1.Book, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	exist, _ := r.entClient.Client().Book.Query().Where(book.IDEQ(id)).Exist(ctx)
	if !exist {
		return nil, ledgerV1.ErrorNotFound("book not found")
	}

	builder := r.entClient.Client().Book.UpdateOneID(id).
		SetNillableName(data.Name).
		SetNillableDefaultCurrencyCode(data.DefaultCurrencyCode).
		SetNillableNotes(data.Notes).
		SetNillableEnable(data.Enable).
		SetNillableExportAt(data.ExportAt).
		SetNillableDefaultExpenseAccountID(data.DefaultExpenseAccountId).
		SetNillableDefaultIncomeAccountID(data.DefaultIncomeAccountId).
		SetNillableDefaultTransferFromAccountID(data.DefaultTransferFromAccountId).
		SetNillableDefaultTransferToAccountID(data.DefaultTransferToAccountId).
		SetNillableDefaultExpenseCategoryID(data.DefaultExpenseCategoryId).
		SetNillableDefaultIncomeCategoryID(data.DefaultIncomeCategoryId).
		SetNillableUpdatedBy(data.UpdatedBy).
		SetUpdatedAt(time.Now())

	updated, err := builder.Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("update book failed")
	}
	return r.mapper.ToDTO(updated), nil
}

func (r *BookRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().Book.DeleteOneID(id).Exec(ctx)
}

func (r *BookRepo) Toggle(ctx context.Context, id uint32) (*ledgerV1.Book, error) {
	entity, err := r.entClient.Client().Book.Query().Where(book.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("book not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get book failed")
	}
	updated, err := r.entClient.Client().Book.UpdateOneID(id).SetEnable(!*entity.Enable).Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("toggle book failed")
	}
	return r.mapper.ToDTO(updated), nil
}

func (r *BookRepo) count(ctx context.Context, whereCond []func(s *sql.Selector)) (int, error) {
	builder := r.entClient.Client().Book.Query()
	if len(whereCond) != 0 {
		builder.Modify(whereCond...)
	}
	return builder.Count(ctx)
}
