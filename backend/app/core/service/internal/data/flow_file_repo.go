package data

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/google/uuid"
	"github.com/minio/minio-go/v7"
	"github.com/tx7do/go-utils/mapper"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	entCrud "github.com/tx7do/go-crud/entgo"

	"go-wind-ledger/app/core/service/internal/data/ent"
	"go-wind-ledger/app/core/service/internal/data/ent/flowfile"

	ledgerV1 "go-wind-ledger/api/gen/go/ledger/service/v1"

	"go-wind-ledger/pkg/oss"
)

// flowFileBucket 流水附件统一存储桶。流水附件对 bucket 划分不敏感，
// 为便于按 id+create_time 定位下载，统一存放在固定 bucket，object_key 形如
// "flow-files/{flow_id}/{uuid}"。
const flowFileBucket = oss.BucketFiles

type FlowFileRepo struct {
	entClient *entCrud.EntClient[*ent.Client]
	log       *log.Helper
	mapper    *mapper.CopierMapper[ledgerV1.FlowFile, ent.FlowFile]
	mc        *oss.MinIOClient
}

func NewFlowFileRepo(
	ctx *bootstrap.Context,
	entClient *entCrud.EntClient[*ent.Client],
	mc *oss.MinIOClient,
) *FlowFileRepo {
	return &FlowFileRepo{
		entClient: entClient,
		log:       ctx.NewLoggerHelper("flowfile/repo/core-service"),
		mapper:    mapper.NewCopierMapper[ledgerV1.FlowFile, ent.FlowFile](),
		mc:        mc,
	}
}

func (r *FlowFileRepo) ListByFlow(ctx context.Context, flowID uint32) ([]*ledgerV1.FlowFile, error) {
	entities, err := r.entClient.Client().FlowFile.Query().Where(flowfile.FlowIDEQ(flowID)).All(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("query flow files failed")
	}
	list := make([]*ledgerV1.FlowFile, 0, len(entities))
	for _, e := range entities {
		list = append(list, r.mapper.ToDTO(e))
	}
	return list, nil
}

func (r *FlowFileRepo) Create(ctx context.Context, data *ledgerV1.FlowFile) (*ledgerV1.FlowFile, error) {
	saved, err := r.entClient.Client().FlowFile.Create().
		SetNillableFlowID(data.FlowId).
		SetNillableCreatorID(data.CreatorId).
		SetNillableCreateTime(data.CreateTime).
		SetNillableContentType(data.ContentType).
		SetNillableSize(data.Size).
		SetNillableOriginalName(data.OriginalName).
		SetCreatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return nil, ledgerV1.ErrorInternalServerError("create flow file failed")
	}
	return r.mapper.ToDTO(saved), nil
}

func (r *FlowFileRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().FlowFile.DeleteOneID(id).Exec(ctx)
}

func (r *FlowFileRepo) DeleteByFlow(ctx context.Context, flowID uint32) error {
	_, err := r.entClient.Client().FlowFile.Delete().Where(flowfile.FlowIDEQ(flowID)).Exec(ctx)
	return err
}

// ReassignFlow updates all attachments from one flow to another (used by BalanceFlow Update).
func (r *FlowFileRepo) ReassignFlow(ctx context.Context, oldFlowID uint32, newFlowID uint32) error {
	_, err := r.entClient.Client().FlowFile.Update().
		Where(flowfile.FlowIDEQ(oldFlowID)).
		SetFlowID(newFlowID).
		Save(ctx)
	return err
}

// UploadFile 上传流水附件：将文件数据写入 MinIO，并落库元数据。
// creatorID 来自认证上下文（由 Service 层注入）。
func (r *FlowFileRepo) UploadFile(ctx context.Context, creatorID uint32, req *ledgerV1.UploadFlowFileRequest) (*ledgerV1.FlowFile, error) {
	if req == nil {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}
	data := req.GetData()
	if len(data) == 0 {
		return nil, ledgerV1.ErrorBadRequest("empty file data")
	}

	contentType := req.GetContentType()
	if contentType == "" {
		contentType = oss.DefaultContentType
	}
	now := time.Now().Unix()

	// 生成 object_key：flow-files/{flow_id}/{uuid}
	objectKey := fmt.Sprintf("flow-files/%d/%s", req.GetFlowId(), uuid.New().String())

	// 若 MinIO client 可用，则上传文件内容；否则仅落库元数据（后续接入）。
	if r.mc != nil {
		mc := r.mc.GetClient()
		if mc != nil {
			if err := r.mc.EnsureBucketExists(ctx, flowFileBucket); err != nil {
				r.log.Errorf("ensure bucket failed: %v", err)
				return nil, ledgerV1.ErrorInternalServerError("ensure bucket failed")
			}
			reader := bytes.NewReader(data)
			if _, err := mc.PutObject(ctx, flowFileBucket, objectKey, reader, reader.Size(),
				minio.PutObjectOptions{ContentType: contentType}); err != nil {
				r.log.Errorf("upload file to minio failed: %v", err)
				return nil, ledgerV1.ErrorInternalServerError("upload file failed")
			}
		}
	}

	saved, err := r.entClient.Client().FlowFile.Create().
		SetFlowID(req.GetFlowId()).
		SetCreatorID(creatorID).
		SetCreateTime(now).
		SetContentType(contentType).
		SetSize(req.GetSize()).
		SetOriginalName(req.GetFileName()).
		SetObjectKey(objectKey).
		SetCreatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		// 落库失败时尽量回滚已上传的对象，避免孤儿文件。
		if r.mc != nil && r.mc.GetClient() != nil {
			_ = r.mc.DeleteFile(ctx, flowFileBucket, objectKey)
		}
		return nil, ledgerV1.ErrorInternalServerError("create flow file failed")
	}

	return r.mapper.ToDTO(saved), nil
}

// ViewFile 查看流水附件（免认证）：按 id 查询，并用 create_time 做安全校验防止遍历。
// 校验通过后从 MinIO 下载文件内容并返回。
func (r *FlowFileRepo) ViewFile(ctx context.Context, req *ledgerV1.ViewFlowFileRequest) (*ledgerV1.ViewFlowFileResponse, error) {
	if req == nil || req.GetId() == 0 {
		return nil, ledgerV1.ErrorBadRequest("invalid request")
	}

	entity, err := r.entClient.Client().FlowFile.Query().
		Where(flowfile.IDEQ(req.GetId())).
		Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, ledgerV1.ErrorNotFound("flow file not found")
		}
		return nil, ledgerV1.ErrorInternalServerError("query flow file failed")
	}

	// create_time 安全校验：防止通过枚举 id 遍历他人附件。
	// entity.CreateTime 为 *int64，空值视为不匹配。
	if entity.CreateTime == nil || *entity.CreateTime != req.GetCreateTime() {
		return nil, ledgerV1.ErrorNotFound("flow file not found")
	}

	resp := &ledgerV1.ViewFlowFileResponse{}
	if entity.ContentType != nil {
		resp.ContentType = *entity.ContentType
	}
	if entity.OriginalName != nil {
		resp.OriginalName = *entity.OriginalName
	}

	// object_key 为空（旧数据或 MinIO 未启用）时无法提供文件内容。
	objectKey := ""
	if entity.ObjectKey != nil {
		objectKey = *entity.ObjectKey
	}
	if objectKey == "" {
		return nil, ledgerV1.ErrorNotFound("file content not available")
	}

	if r.mc == nil || r.mc.GetClient() == nil {
		return nil, ledgerV1.ErrorInternalServerError("storage client unavailable")
	}

	obj, err := r.mc.GetClient().GetObject(ctx, flowFileBucket, objectKey, minio.GetObjectOptions{})
	if err != nil {
		r.log.Errorf("get object from minio failed: %v", err)
		return nil, ledgerV1.ErrorInternalServerError("get file failed")
	}
	defer obj.Close()

	content, err := io.ReadAll(obj)
	if err != nil {
		r.log.Errorf("read object from minio failed: %v", err)
		return nil, ledgerV1.ErrorInternalServerError("read file failed")
	}
	resp.Data = content

	return resp, nil
}
