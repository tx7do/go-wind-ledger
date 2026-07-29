package data

import (
	"context"
	"time"

	"entgo.io/ent/dialect/sql"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	paginationV1 "github.com/tx7do/go-crud/api/gen/go/pagination/v1"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/mapper"

	"go-wind-ledger/app/core/service/internal/data/ent"
	"go-wind-ledger/app/core/service/internal/data/ent/file"
	"go-wind-ledger/app/core/service/internal/data/ent/predicate"

	storageV1 "go-wind-ledger/api/gen/go/storage/service/v1"
)

type FileRepo struct {
	entClient  *entCrud.EntClient[*ent.Client]
	log        *log.Helper
	mapper     *mapper.CopierMapper[storageV1.File, ent.File]
	repository *entCrud.Repository[
		ent.FileQuery, ent.FileSelect,
		ent.FileCreate, ent.FileCreateBulk,
		ent.FileUpdate, ent.FileUpdateOne,
		ent.FileDelete,
		predicate.File,
		storageV1.File, ent.File,
	]
}

func NewFileRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *FileRepo {
	repo := &FileRepo{
		log:       ctx.NewLoggerHelper("file/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[storageV1.File, ent.File](),
	}
	repo.init()
	return repo
}

func (r *FileRepo) init() {
	r.repository = entCrud.NewRepository[
		ent.FileQuery, ent.FileSelect,
		ent.FileCreate, ent.FileCreateBulk,
		ent.FileUpdate, ent.FileUpdateOne,
		ent.FileDelete,
		predicate.File,
		storageV1.File, ent.File,
	](r.mapper)
}

func (r *FileRepo) Count(ctx context.Context, whereCond []func(s *sql.Selector)) (int, error) {
	builder := r.entClient.Client().File.Query()
	if len(whereCond) != 0 {
		builder.Modify(whereCond...)
	}
	return builder.Count(ctx)
}

func (r *FileRepo) List(ctx context.Context, req *paginationV1.PagingRequest) (*storageV1.ListFileResponse, error) {
	if req == nil {
		return nil, storageV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().File.Query()
	ret, err := r.repository.ListWithPaging(ctx, builder, builder.Clone(), req)
	if err != nil {
		return nil, err
	}
	if ret == nil {
		return &storageV1.ListFileResponse{Total: 0}, nil
	}
	return &storageV1.ListFileResponse{Total: ret.Total, Items: ret.Items}, nil
}

func (r *FileRepo) IsExist(ctx context.Context, id uint32) (bool, error) {
	return r.entClient.Client().File.Query().Where(file.IDEQ(id)).Exist(ctx)
}

func (r *FileRepo) Get(ctx context.Context, req *storageV1.GetFileRequest) (*storageV1.File, error) {
	entity, err := r.entClient.Client().File.Query().Where(file.IDEQ(req.GetId())).Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, storageV1.ErrorNotFound("file not found")
		}
		return nil, storageV1.ErrorInternalServerError("get file failed")
	}
	return r.mapper.ToDTO(entity), nil
}

func (r *FileRepo) Create(ctx context.Context, req *storageV1.CreateFileRequest) (*storageV1.File, error) {
	if req == nil || req.Data == nil {
		return nil, storageV1.ErrorBadRequest("invalid parameter")
	}
	data := req.Data
	builder := r.entClient.Client().File.Create().
		SetNillableName(data.FileName).
		SetNillableOriginalName(data.FileName).
		SetNillableContentType(data.Extension).
		SetNillableURL(data.LinkUrl).
		SetNillableObjectKey(data.SaveFileName).
		SetNillableCreatedBy(data.CreatedBy).
		SetCreatedAt(time.Now())

	saved, err := builder.Save(ctx)
	if err != nil {
		return nil, storageV1.ErrorInternalServerError("create file failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *FileRepo) Update(ctx context.Context, req *storageV1.UpdateFileRequest) error {
	if req == nil || req.Data == nil {
		return storageV1.ErrorBadRequest("invalid parameter")
	}
	data := req.Data
	_, err := r.entClient.Client().File.UpdateOneID(req.GetId()).
		SetNillableName(data.FileName).
		SetUpdatedAt(time.Now()).
		Save(ctx)
	return err
}

func (r *FileRepo) Delete(ctx context.Context, req *storageV1.DeleteFileRequest) error {
	return r.entClient.Client().File.DeleteOneID(req.GetId()).Exec(ctx)
}
