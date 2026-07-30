package data

import (
	"context"
	"time"

	"entgo.io/ent/dialect/sql"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/copierutil"
	"github.com/tx7do/go-utils/mapper"

	"go-wind-ledger/app/core/service/internal/data/ent"
	"go-wind-ledger/app/core/service/internal/data/ent/category"
	"go-wind-ledger/app/core/service/internal/data/ent/predicate"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

type CategoryRepo struct {
	entClient  *entCrud.EntClient[*ent.Client]
	log        *log.Helper
	mapper     *mapper.CopierMapper[ledgerV1.Category, ent.Category]
	typeConverter *mapper.EnumTypeConverter[ledgerV1.CategoryType, category.Type]
	repository *entCrud.Repository[
		ent.CategoryQuery, ent.CategorySelect,
		ent.CategoryCreate, ent.CategoryCreateBulk,
		ent.CategoryUpdate, ent.CategoryUpdateOne,
		ent.CategoryDelete,
		predicate.Category,
		ledgerV1.Category, ent.Category,
	]
}

func NewCategoryRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *CategoryRepo {
	repo := &CategoryRepo{
		log:       ctx.NewLoggerHelper("category/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[ledgerV1.Category, ent.Category](),
		typeConverter: mapper.NewEnumTypeConverter[ledgerV1.CategoryType, category.Type](
			ledgerV1.CategoryType_name, ledgerV1.CategoryType_value,
		),
	}
	repo.init()
	return repo
}

func (r *CategoryRepo) init() {
	r.repository = entCrud.NewRepository[
		ent.CategoryQuery, ent.CategorySelect,
		ent.CategoryCreate, ent.CategoryCreateBulk,
		ent.CategoryUpdate, ent.CategoryUpdateOne,
		ent.CategoryDelete,
		predicate.Category,
		ledgerV1.Category, ent.Category,
	](r.mapper)
	r.mapper.AppendConverters(copierutil.NewTimeStringConverterPair())
	r.mapper.AppendConverters(copierutil.NewTimeTimestamppbConverterPair())
	r.mapper.AppendConverters(r.typeConverter.NewConverterPair())
}

func (r *CategoryRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListCategoryResponse, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Category.Query()
	ret, err := r.repository.ListWithPaging(ctx, builder, builder.Clone(), req)
	if err != nil {
		return nil, err
	}
	if ret == nil {
		return &ledgerV1.ListCategoryResponse{Total: 0}, nil
	}
	return &ledgerV1.ListCategoryResponse{Total: ret.Total, Items: ret.Items}, nil
}

func (r *CategoryRepo) ListAll(ctx context.Context, bookID uint32, typ *ledgerV1.CategoryType) (*ledgerV1.ListCategoryResponse, error) {
	q := r.entClient.Client().Category.Query().
		Where(category.BookIDEQ(bookID), category.EnableEQ(true))
	if typ != nil && *typ != ledgerV1.CategoryType_CATEGORY_TYPE_UNSPECIFIED {
		q = q.Where(category.TypeEQ(category.Type(typ.String())))
	}
	entities, err := q.All(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query categories failed")
	}
	items := make([]*ledgerV1.Category, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &ledgerV1.ListCategoryResponse{Items: items, Total: uint64(len(items))}, nil
}

func (r *CategoryRepo) Get(ctx context.Context, id uint32) (*ledgerV1.Category, error) {
	entity, err := r.entClient.Client().Category.Query().Where(category.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("category not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get category failed")
	}
	return r.mapper.ToDTO(entity), nil
}

func (r *CategoryRepo) Create(ctx context.Context, data *ledgerV1.Category) (*ledgerV1.Category, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Category.Create().
		SetNillableBookID(data.BookId).
		SetNillableName(data.Name).
		SetNillableNotes(data.Notes).
		SetNillableEnable(data.Enable).
		SetNillableDepth(data.Depth).
		SetNillableParentID(data.ParentId).
		SetNillableCreatedBy(data.CreatedBy).
		SetCreatedAt(time.Now())

	if data.Type != nil {
		builder = builder.SetType(category.Type(data.Type.String()))
	}

	saved, err := builder.Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("create category failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *CategoryRepo) Update(ctx context.Context, id uint32, data *ledgerV1.Category, mask *fieldmaskpb.FieldMask) (*ledgerV1.Category, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Category.UpdateOneID(id).
		SetNillableName(data.Name).
		SetNillableNotes(data.Notes).
		SetNillableEnable(data.Enable).
		SetNillableDepth(data.Depth).
		SetNillableParentID(data.ParentId).
		SetNillableUpdatedBy(data.UpdatedBy).
		SetUpdatedAt(time.Now())

	updated, err := builder.Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("update category failed")
	}
	return r.mapper.ToDTO(updated), nil
}

func (r *CategoryRepo) Delete(ctx context.Context, id uint32) error {
	count, _ := r.entClient.Client().CategoryRelation.Query().
		Where(func(s *sql.Selector) { s.Where(sql.EQ("category_id", id)) }).Count(ctx)
	if count > 0 {
		return ledgerV1.ErrorConflict("category has related balance flows, cannot delete")
	}
	return r.entClient.Client().Category.DeleteOneID(id).Exec(ctx)
}

func (r *CategoryRepo) Toggle(ctx context.Context, id uint32) (*ledgerV1.Category, error) {
	entity, err := r.entClient.Client().Category.Query().Where(category.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("category not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get category failed")
	}
	updated, _ := r.entClient.Client().Category.UpdateOneID(id).SetEnable(!*entity.Enable).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}

func (r *CategoryRepo) UnChildren(ctx context.Context, parentID uint32) error {
	_, err := r.entClient.Client().Category.Update().Where(category.ParentIDEQ(parentID)).ClearParentID().Save(ctx)
	return err
}
