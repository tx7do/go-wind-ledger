package data

import (
	"context"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/mapper"
	"github.com/tx7do/go-utils/timeutil"
	"github.com/tx7do/kratos-bootstrap/bootstrap"
	"google.golang.org/protobuf/types/known/fieldmaskpb"

	"go-wind-ledger/app/core/service/internal/data/ent"
	"go-wind-ledger/app/core/service/internal/data/ent/membership"

	identityV1 "go-wind-ledger/api/gen/go/identity/service/v1"
)

// MembershipRepo 成员关系仓库（用于用户-租户关联）
type MembershipRepo struct {
	log       *log.Helper
	entClient *entCrud.EntClient[*ent.Client]
	mapper    *mapper.CopierMapper[identityV1.Membership, ent.Membership]
	statusConverter *mapper.EnumTypeConverter[identityV1.Membership_Status, membership.Status]
}

func NewMembershipRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *MembershipRepo {
	repo := &MembershipRepo{
		log:       ctx.NewLoggerHelper("membership/repo/core-service"),
		entClient: entClient,
		mapper:    mapper.NewCopierMapper[identityV1.Membership, ent.Membership](),
		statusConverter: mapper.NewEnumTypeConverter[identityV1.Membership_Status, membership.Status](
			identityV1.Membership_Status_name, identityV1.Membership_Status_value,
		),
	}
	repo.mapper.AppendConverters(repo.statusConverter.NewConverterPair())
	return repo
}

// AssignTenantMembershipWith 为用户分配租户成员关系（含事务）
func (r *MembershipRepo) AssignTenantMembershipWith(ctx context.Context, data *identityV1.Membership) (err error) {
	var tx *ent.Tx
	tx, err = r.entClient.Client().Tx(ctx)
	if err != nil {
		r.log.Errorf("start transaction failed: %s", err.Error())
		return identityV1.ErrorInternalServerError("start transaction failed")
	}
	defer func() {
		if err != nil {
			if rollbackErr := tx.Rollback(); rollbackErr != nil {
				r.log.Errorf("transaction rollback failed: %s", rollbackErr.Error())
			}
			return
		}
		if commitErr := tx.Commit(); commitErr != nil {
			r.log.Errorf("transaction commit failed: %s", commitErr.Error())
			err = identityV1.ErrorInternalServerError("transaction commit failed")
		}
	}()

	return r.AssignTenantMembershipWithTx(ctx, tx, data)
}

// AssignTenantMembershipWithTx 使用 Membership 数据为用户分配租户（事务内）
func (r *MembershipRepo) AssignTenantMembershipWithTx(ctx context.Context, tx *ent.Tx, data *identityV1.Membership) (err error) {
	_, err = r.upsertMembership(ctx, tx, data)
	return err
}

// GetMembershipByUserTenant 获取用户在指定租户的成员关系
func (r *MembershipRepo) GetMembershipByUserTenant(ctx context.Context, userID uint32) (*identityV1.Membership, error) {
	entity, err := r.entClient.Client().Membership.Query().
		Where(membership.UserIDEQ(userID)).
		First(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, identityV1.ErrorNotFound("membership not found")
		}
		return nil, identityV1.ErrorInternalServerError("query membership failed")
	}
	return r.mapper.ToDTO(entity), nil
}

// GetMembershipID 获取用户的成员关系ID
func (r *MembershipRepo) GetMembershipID(ctx context.Context, userID uint32) (uint32, error) {
	entity, err := r.entClient.Client().Membership.Query().
		Where(membership.UserIDEQ(userID)).
		First(ctx)
	if err != nil {
		return 0, err
	}
	return entity.ID, nil
}

// === 内部方法 ===

func (r *MembershipRepo) upsertMembership(ctx context.Context, tx *ent.Tx, data *identityV1.Membership) (*ent.Membership, error) {
	// Check if membership already exists for this user+tenant
	existing, err := tx.Membership.Query().
		Where(
			membership.UserIDEQ(data.GetUserId()),
			membership.TenantIDEQ(data.GetTenantId()),
		).
		First(ctx)
	if err == nil && existing != nil {
		// Update existing membership
		builder := tx.Membership.UpdateOneID(existing.ID)
		if data.Status != nil {
			builder = builder.SetStatus(membership.Status(data.Status.String()))
		}
		if data.IsPrimary != nil {
			builder = builder.SetIsPrimary(*data.IsPrimary)
		}
		builder = builder.SetUpdatedAt(time.Now())
		return builder.Save(ctx)
	}

	// Create new membership
	builder := tx.Membership.Create().
		SetUserID(data.GetUserId()).
		SetTenantID(data.GetTenantId()).
		SetNillableIsPrimary(data.IsPrimary).
		SetCreatedAt(time.Now())

	if data.Status != nil {
		builder = builder.SetStatus(membership.Status(data.Status.String()))
	}

	return builder.Save(ctx)
}

// === TenantMember Service 数据访问方法 ===

// ListByTenant 按 tenant_id + 可选 status 过滤查询成员列表
func (r *MembershipRepo) ListByTenant(ctx context.Context, tenantID uint32, status *identityV1.Membership_Status) ([]*identityV1.Membership, error) {
	q := r.entClient.Client().Membership.Query().
		Where(membership.TenantIDEQ(tenantID))
	if status != nil {
		q = q.Where(membership.StatusEQ(membership.Status(status.String())))
	}
	entities, err := q.All(ctx)
	if err != nil {
		r.log.Errorf("list membership by tenant failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("list membership failed")
	}
	items := make([]*identityV1.Membership, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return items, nil
}

// FindByTenantAndUser 查找特定租户+用户的成员关系
func (r *MembershipRepo) FindByTenantAndUser(ctx context.Context, tenantID, userID uint32) (*identityV1.Membership, error) {
	entity, err := r.entClient.Client().Membership.Query().
		Where(
			membership.TenantIDEQ(tenantID),
			membership.UserIDEQ(userID),
		).
		Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, identityV1.ErrorNotFound("membership not found")
		}
		r.log.Errorf("find membership by tenant and user failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("find membership failed")
	}
	return r.mapper.ToDTO(entity), nil
}

// FindByUser 查找用户所有租户成员关系
func (r *MembershipRepo) FindByUser(ctx context.Context, userID uint32) ([]*identityV1.Membership, error) {
	entities, err := r.entClient.Client().Membership.Query().
		Where(membership.UserIDEQ(userID)).
		All(ctx)
	if err != nil {
		r.log.Errorf("find membership by user failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("find membership failed")
	}
	items := make([]*identityV1.Membership, 0, len(entities))
	for _, e := range entities {
		items = append(items, r.mapper.ToDTO(e))
	}
	return items, nil
}

// FindByID 按 id 查询成员关系
func (r *MembershipRepo) FindByID(ctx context.Context, id uint32) (*identityV1.Membership, error) {
	entity, err := r.entClient.Client().Membership.Query().
		Where(membership.IDEQ(id)).
		Only(ctx)
	if err != nil {
		if ent.IsNotFound(err) {
			return nil, identityV1.ErrorNotFound("membership not found")
		}
		r.log.Errorf("find membership by id failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("find membership failed")
	}
	return r.mapper.ToDTO(entity), nil
}

// Create 创建成员关系
func (r *MembershipRepo) Create(ctx context.Context, data *identityV1.Membership) (*identityV1.Membership, error) {
	if data == nil {
		return nil, identityV1.ErrorBadRequest("invalid parameter")
	}
	builder := r.entClient.Client().Membership.Create().
		SetTenantID(data.GetTenantId()).
		SetUserID(data.GetUserId()).
		SetNillableIsPrimary(data.IsPrimary).
		SetNillableRoleID(data.RoleId).
		SetNillableCreatedBy(data.CreatedBy).
		SetCreatedAt(time.Now())
	if data.Status != nil {
		builder = builder.SetStatus(membership.Status(data.Status.String()))
	}
	if data.JoinedAt != nil {
		builder = builder.SetNillableJoinedAt(timeutil.TimestamppbToTime(data.JoinedAt))
	}
	if data.StartAt != nil {
		builder = builder.SetNillableStartAt(timeutil.TimestamppbToTime(data.StartAt))
	}
	if data.EndAt != nil {
		builder = builder.SetNillableEndAt(timeutil.TimestamppbToTime(data.EndAt))
	}
	saved, err := builder.Save(ctx)
	if err != nil {
		r.log.Errorf("create membership failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("create membership failed")
	}
	return r.mapper.ToDTO(saved), nil
}

// UpdateStatus 更新成员状态（用于 accept/reject）
func (r *MembershipRepo) UpdateStatus(ctx context.Context, id uint32, status identityV1.Membership_Status) (*identityV1.Membership, error) {
	exist, _ := r.entClient.Client().Membership.Query().Where(membership.IDEQ(id)).Exist(ctx)
	if !exist {
		return nil, identityV1.ErrorNotFound("membership not found")
	}
	updated, err := r.entClient.Client().Membership.UpdateOneID(id).
		SetStatus(membership.Status(status.String())).
		SetUpdatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		r.log.Errorf("update membership status failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("update membership status failed")
	}
	return r.mapper.ToDTO(updated), nil
}

// SetJoinedAt 设置成员的加入时间
func (r *MembershipRepo) SetJoinedAt(ctx context.Context, id uint32, joinedAt time.Time) (*identityV1.Membership, error) {
	updated, err := r.entClient.Client().Membership.UpdateOneID(id).
		SetJoinedAt(joinedAt).
		SetUpdatedAt(time.Now()).
		Save(ctx)
	if err != nil {
		r.log.Errorf("set membership joined_at failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("update membership failed")
	}
	return r.mapper.ToDTO(updated), nil
}

// Update 更新成员信息
func (r *MembershipRepo) Update(ctx context.Context, id uint32, data *identityV1.Membership, mask *fieldmaskpb.FieldMask) (*identityV1.Membership, error) {
	if data == nil {
		return nil, identityV1.ErrorBadRequest("invalid parameter")
	}
	exist, _ := r.entClient.Client().Membership.Query().Where(membership.IDEQ(id)).Exist(ctx)
	if !exist {
		return nil, identityV1.ErrorNotFound("membership not found")
	}
	builder := r.entClient.Client().Membership.UpdateOneID(id).SetUpdatedAt(time.Now())
	applyAll := mask == nil || len(mask.Paths) == 0
	if applyAll {
		builder = builder.
			SetNillableIsPrimary(data.IsPrimary).
			SetNillableRoleID(data.RoleId).
			SetNillableUpdatedBy(data.UpdatedBy)
		if data.Status != nil {
			builder = builder.SetStatus(membership.Status(data.Status.String()))
		}
		if data.JoinedAt != nil {
			builder = builder.SetNillableJoinedAt(timeutil.TimestamppbToTime(data.JoinedAt))
		}
		if data.StartAt != nil {
			builder = builder.SetNillableStartAt(timeutil.TimestamppbToTime(data.StartAt))
		}
		if data.EndAt != nil {
			builder = builder.SetNillableEndAt(timeutil.TimestamppbToTime(data.EndAt))
		}
	} else {
		for _, path := range mask.Paths {
			switch path {
			case "is_primary":
				builder = builder.SetNillableIsPrimary(data.IsPrimary)
			case "role_id":
				builder = builder.SetNillableRoleID(data.RoleId)
			case "status":
				if data.Status != nil {
					builder = builder.SetStatus(membership.Status(data.Status.String()))
				}
			case "joined_at":
				if data.JoinedAt != nil {
					builder = builder.SetNillableJoinedAt(timeutil.TimestamppbToTime(data.JoinedAt))
				}
			case "start_at":
				if data.StartAt != nil {
					builder = builder.SetNillableStartAt(timeutil.TimestamppbToTime(data.StartAt))
				}
			case "end_at":
				if data.EndAt != nil {
					builder = builder.SetNillableEndAt(timeutil.TimestamppbToTime(data.EndAt))
				}
			case "updated_by":
				builder = builder.SetNillableUpdatedBy(data.UpdatedBy)
			}
		}
	}
	updated, err := builder.Save(ctx)
	if err != nil {
		r.log.Errorf("update membership failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("update membership failed")
	}
	return r.mapper.ToDTO(updated), nil
}

// Delete 删除成员
func (r *MembershipRepo) Delete(ctx context.Context, id uint32) error {
	return r.entClient.Client().Membership.DeleteOneID(id).Exec(ctx)
}

// DeleteByTenantAndUser 按 tenant+user 删除成员
func (r *MembershipRepo) DeleteByTenantAndUser(ctx context.Context, tenantID, userID uint32) error {
	_, err := r.entClient.Client().Membership.Delete().
		Where(
			membership.TenantIDEQ(tenantID),
			membership.UserIDEQ(userID),
		).
		Exec(ctx)
	return err
}
