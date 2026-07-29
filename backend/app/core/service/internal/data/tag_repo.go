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
	"go-wind-ledger/app/core/service/internal/data/ent/predicate"
	"go-wind-ledger/app/core/service/internal/data/ent/tag"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"
)

type TagRepo struct {
	entClient  *entCrud.EntClient[*ent.Client]
	log        *log.Helper
	mapper     *mapper.CopierMapper[ledgerV1.Tag, ent.Tag]
	repository *entCrud.Repository[
		ent.TagQuery, ent.TagSelect,
		ent.TagCreate, ent.TagCreateBulk,
		ent.TagUpdate, ent.TagUpdateOne,
		ent.TagDelete,
		predicate.Tag,
		ledgerV1.Tag, ent.Tag,
	]
}

func NewTagRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *TagRepo {
	repo := &TagRepo{
		log:       ctx.NewLoggerHelper("tag/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[ledgerV1.Tag, ent.Tag](),
	}
	repo.init()
	return repo
}

func (r *TagRepo) init() {
	r.repository = entCrud.NewRepository[
		ent.TagQuery, ent.TagSelect,
		ent.TagCreate, ent.TagCreateBulk,
		ent.TagUpdate, ent.TagUpdateOne,
		ent.TagDelete,
		predicate.Tag,
		ledgerV1.Tag, ent.Tag,
	](r.mapper)
	r.mapper.AppendConverters(copierutil.NewTimeStringConverterPair())
	r.mapper.AppendConverters(copierutil.NewTimeTimestamppbConverterPair())
}

func (r *TagRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*ledgerV1.ListTagResponse, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Tag.Query()
	ret, err := r.repository.ListWithPaging(ctx, builder, builder.Clone(), req)
	if err != nil {
		return nil, err
	}
	if ret == nil {
		return &ledgerV1.ListTagResponse{Total: 0}, nil
	}
	return &ledgerV1.ListTagResponse{Total: ret.Total, Items: ret.Items}, nil
}

func (r *TagRepo) ListAll(ctx context.Context, bookID uint32) (*ledgerV1.ListTagResponse, error) {
	q := r.entClient.Client().Tag.Query().Where(tag.BookIDEQ(bookID), tag.EnableEQ(true))
	entities, err := q.All(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query tags failed")
	}
	items := make([]*ledgerV1.Tag, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return &ledgerV1.ListTagResponse{Items: items, Total: uint64(len(items))}, nil
}

func (r *TagRepo) Get(ctx context.Context, id uint32) (*ledgerV1.Tag, error) {
	entity, err := r.entClient.Client().Tag.Query().Where(tag.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("tag not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get tag failed")
	}
	return r.mapper.ToDTO(entity), nil
}

func (r *TagRepo) Create(ctx context.Context, data *ledgerV1.Tag) (*ledgerV1.Tag, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	saved, err := r.entClient.Client().Tag.Create().
		SetNillableBookID(data.BookId).
		SetNillableName(data.Name).
		SetNillableNotes(data.Notes).
		SetNillableEnable(data.Enable).
		SetNillableCanExpense(data.CanExpense).
		SetNillableCanIncome(data.CanIncome).
		SetNillableCanTransfer(data.CanTransfer).
		SetNillableDepth(data.Depth).
		SetNillableParentID(data.ParentId).
		SetNillableCreatedBy(data.CreatedBy).
		SetCreatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("create tag failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *TagRepo) Update(ctx context.Context, id uint32, data *ledgerV1.Tag, mask *fieldmaskpb.FieldMask) (*ledgerV1.Tag, error) {
	if data == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid parameter")
	}
	updated, err := r.entClient.Client().Tag.UpdateOneID(id).
		SetNillableName(data.Name).
		SetNillableNotes(data.Notes).
		SetNillableEnable(data.Enable).
		SetNillableCanExpense(data.CanExpense).
		SetNillableCanIncome(data.CanIncome).
		SetNillableCanTransfer(data.CanTransfer).
		SetNillableDepth(data.Depth).
		SetNillableParentID(data.ParentId).
		SetNillableUpdatedBy(data.UpdatedBy).
		SetUpdatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("update tag failed")
	}
	return r.mapper.ToDTO(updated), nil
}

func (r *TagRepo) Delete(ctx context.Context, id uint32) error {
	// Check if tag has relations with balance flows before deleting
	count, _ := r.entClient.Client().TagRelation.Query().
		Where(func(s *sql.Selector) { s.Where(sql.EQ("tag_id", id)) }).Count(ctx)
	if count > 0 {
		return ledgerV1.ErrorConflict("tag has related balance flows, cannot delete")
	}
	return r.entClient.Client().Tag.DeleteOneID(id).Exec(ctx)
}

func (r *TagRepo) Toggle(ctx context.Context, id uint32) (*ledgerV1.Tag, error) {
	entity, err := r.entClient.Client().Tag.Query().Where(tag.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("tag not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get tag failed")
	}
	updated, _ := r.entClient.Client().Tag.UpdateOneID(id).SetEnable(!*entity.Enable).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}

func (r *TagRepo) ToggleCanExpense(ctx context.Context, id uint32) (*ledgerV1.Tag, error) {
	entity, err := r.entClient.Client().Tag.Query().Where(tag.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("tag not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get tag failed")
	}
	updated, _ := r.entClient.Client().Tag.UpdateOneID(id).SetCanExpense(!*entity.CanExpense).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}

func (r *TagRepo) ToggleCanIncome(ctx context.Context, id uint32) (*ledgerV1.Tag, error) {
	entity, err := r.entClient.Client().Tag.Query().Where(tag.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("tag not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get tag failed")
	}
	updated, _ := r.entClient.Client().Tag.UpdateOneID(id).SetCanIncome(!*entity.CanIncome).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}

func (r *TagRepo) ToggleCanTransfer(ctx context.Context, id uint32) (*ledgerV1.Tag, error) {
	entity, err := r.entClient.Client().Tag.Query().Where(tag.IDEQ(id)).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("tag not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("get tag failed")
	}
	updated, _ := r.entClient.Client().Tag.UpdateOneID(id).SetCanTransfer(!*entity.CanTransfer).Save(ctx)
	return r.mapper.ToDTO(updated), nil
}

func (r *TagRepo) UnChildren(ctx context.Context, parentID uint32) error {
	_, err := r.entClient.Client().Tag.Update().Where(tag.ParentIDEQ(parentID)).ClearParentID().Save(ctx)
	return err
}
