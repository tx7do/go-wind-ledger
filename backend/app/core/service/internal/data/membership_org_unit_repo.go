package data

import (
	"context"
	"time"

	"github.com/go-kratos/kratos/v2/log"
	entCrud "github.com/tx7do/go-crud/entgo"
	"github.com/tx7do/go-utils/timeutil"
	"github.com/tx7do/kratos-bootstrap/bootstrap"

	"go-wind-cms/app/core/service/internal/data/ent"
	"go-wind-cms/app/core/service/internal/data/ent/membershiporgunit"

	identityV1 "go-wind-cms/api/gen/go/identity/service/v1"
)

type MembershipOrgUnitRepo struct {
	log *log.Helper

	entClient       *entCrud.EntClient[*ent.Client]
}

func NewMembershipOrgUnitRepo(ctx *bootstrap.Context, entClient *entCrud.EntClient[*ent.Client]) *MembershipOrgUnitRepo {
	repo := &MembershipOrgUnitRepo{
		log:       ctx.NewLoggerHelper("membershiporgunit/repo/core-service"),
		entClient: entClient,
	}
	return repo
}


func (r *MembershipOrgUnitRepo) CleanRelationsByMembershipID(ctx context.Context, tx *ent.Tx, membershipID uint32) error {
	if membershipID == 0 {
		return nil
	}

	if _, err := tx.MembershipOrgUnit.Delete().
		Where(
			membershiporgunit.MembershipIDEQ(membershipID),
		).
		Exec(ctx); err != nil {
		r.log.Errorf("delete old membership orgUnits failed: %s", err.Error())
		return identityV1.ErrorInternalServerError("delete old membership orgUnits failed")
	}
	return nil
}

// CleanRelationsByMembershipIDs 清理多个会员组织单元关联
func (r *MembershipOrgUnitRepo) CleanRelationsByMembershipIDs(ctx context.Context, tx *ent.Tx, membershipIDs []uint32) error {
	if len(membershipIDs) == 0 {
		return nil
	}

	if _, err := tx.MembershipOrgUnit.Delete().
		Where(
			membershiporgunit.MembershipIDIn(membershipIDs...),
		).
		Exec(ctx); err != nil {
		r.log.Errorf("delete old membership orgUnits by membership ids failed: %s", err.Error())
		return identityV1.ErrorInternalServerError("delete old membership orgUnits by membership ids failed")
	}
	return nil
}

// CleanRelationsByOrgUnitID 清理组织单元的会员关联
func (r *MembershipOrgUnitRepo) CleanRelationsByOrgUnitID(ctx context.Context, tx *ent.Tx, orgUnitID uint32) error {
	if orgUnitID == 0 {
		return nil
	}

	if _, err := tx.MembershipOrgUnit.Delete().
		Where(
			membershiporgunit.OrgUnitIDEQ(orgUnitID),
		).
		Exec(ctx); err != nil {
		r.log.Errorf("delete old membership orgUnits by orgUnit id failed: %s", err.Error())
		return identityV1.ErrorInternalServerError("delete old membership orgUnits by orgUnit id failed")
	}
	return nil
}

// CleanRelationsByOrgUnitIDs 清理多个组织单元的会员关联
func (r *MembershipOrgUnitRepo) CleanRelationsByOrgUnitIDs(ctx context.Context, tx *ent.Tx, orgUnitIDs []uint32) error {
	if len(orgUnitIDs) == 0 {
		return nil
	}

	if _, err := tx.MembershipOrgUnit.Delete().
		Where(
			membershiporgunit.OrgUnitIDIn(orgUnitIDs...),
		).
		Exec(ctx); err != nil {
		r.log.Errorf("delete old membership orgUnits by orgUnit ids failed: %s", err.Error())
		return identityV1.ErrorInternalServerError("delete old membership orgUnits by orgUnit ids failed")
	}
	return nil
}

// RemoveOrgUnitsFromMembership 删除会员的组织单元关联
func (r *MembershipOrgUnitRepo) RemoveOrgUnitsFromMembership(ctx context.Context, membershipID uint32, ids []uint32) error {
	if membershipID == 0 || len(ids) == 0 {
		return nil
	}

	_, err := r.entClient.Client().MembershipOrgUnit.Delete().
		Where(
			membershiporgunit.And(
				membershiporgunit.MembershipIDEQ(membershipID),
				membershiporgunit.OrgUnitIDIn(ids...),
			),
		).
		Exec(ctx)
	if err != nil {
		r.log.Errorf("remove orgUnits failed: %s", err.Error())
		return identityV1.ErrorInternalServerError("remove orgUnits failed")
	}
	return nil
}

// AssignMembershipOrgUnits 分配组织单元给会员
func (r *MembershipOrgUnitRepo) AssignMembershipOrgUnits(
	ctx context.Context,
	tx *ent.Tx,
	membershipID uint32,
	datas []*identityV1.MembershipOrgUnit,
) error {
	if len(datas) == 0 || membershipID == 0 {
		return nil
	}

	var err error

	// 删除该角色的所有旧关联
	if err = r.CleanRelationsByMembershipID(ctx, tx, membershipID); err != nil {
		return identityV1.ErrorInternalServerError("clean old membership orgUnits failed")
	}


	var membershipOrgUnitCreates []*ent.MembershipOrgUnitCreate
	for _, data := range datas {
		if data.StartAt == nil {
			data.StartAt = timeutil.TimeToTimestamppb(nowAddr())
		}
		rm := tx.MembershipOrgUnit.
			Create().
			SetMembershipID(data.GetMembershipId()).
			SetOrgUnitID(data.GetOrgUnitId()).
			SetNillableCreatedBy(data.CreatedBy).
			SetCreatedAt(time.Now())
		membershipOrgUnitCreates = append(membershipOrgUnitCreates, rm)
	}

	_, err = tx.MembershipOrgUnit.CreateBulk(membershipOrgUnitCreates...).Save(ctx)
	if err != nil {
		r.log.Errorf("assign orgUnit to membership failed: %s", err.Error())
		return identityV1.ErrorInternalServerError("assign orgUnit to membership failed")
	}

	return nil
}

// ListOrgUnitIDs 列出角色关联的组织单元ID列表
func (r *MembershipOrgUnitRepo) ListOrgUnitIDs(ctx context.Context, membershipID uint32, excludeExpired bool) ([]uint32, error) {
	if membershipID == 0 {
		return []uint32{}, nil
	}

	q := r.entClient.Client().MembershipOrgUnit.Query().
		Where(
			membershiporgunit.MembershipIDEQ(membershipID),
		)

	if excludeExpired {
		q = q.Where(
			membershiporgunit.Or(
			),
		)
	}

	intIDs, err := q.
		Select(membershiporgunit.FieldOrgUnitID).
		Ints(ctx)
	if err != nil {
		r.log.Errorf("query orgUnit ids by membership id failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("query orgUnit ids by membership id failed")
	}
	ids := make([]uint32, len(intIDs))
	for i, v := range intIDs {
		ids[i] = uint32(v)
	}
	return ids, nil
}

// ListMembershipIDs 获取组织单元关联的会员ID列表
func (r *MembershipOrgUnitRepo) ListMembershipIDs(ctx context.Context, orgUnitID uint32, excludeExpired bool) ([]uint32, error) {
	if orgUnitID == 0 {
		return []uint32{}, nil
	}

	q := r.entClient.Client().MembershipOrgUnit.Query().
		Where(
			membershiporgunit.OrgUnitIDEQ(orgUnitID),
		)

	if excludeExpired {
		q = q.Where(
			membershiporgunit.Or(
			),
		)
	}

	intIDs, err := q.
		Select(membershiporgunit.FieldMembershipID).
		Ints(ctx)
	if err != nil {
		r.log.Errorf("query membership ids by orgUnit id failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("query membership ids by orgUnit id failed")
	}
	ids := make([]uint32, len(intIDs))
	for i, v := range intIDs {
		ids[i] = uint32(v)
	}
	return ids, nil
}

// ListMembershipIDsByOrgUnitIDs 获取多个组织单元关联的会员ID列表
func (r *MembershipOrgUnitRepo) ListMembershipIDsByOrgUnitIDs(ctx context.Context, orgUnitIDs []uint32, excludeExpired bool) ([]uint32, error) {
	if len(orgUnitIDs) == 0 {
		return nil, nil
	}

	q := r.entClient.Client().MembershipOrgUnit.Query().
		Where(
			membershiporgunit.OrgUnitIDIn(orgUnitIDs...),
		)

	if excludeExpired {
		q = q.Where(
			membershiporgunit.Or(
			),
		)
	}

	intIDs, err := q.
		Select(membershiporgunit.FieldMembershipID).
		Ints(ctx)
	if err != nil {
		r.log.Errorf("query membership ids by orgUnit ids failed: %s", err.Error())
		return nil, identityV1.ErrorInternalServerError("query membership ids by orgUnit ids failed")
	}
	ids := make([]uint32, len(intIDs))
	for i, v := range intIDs {
		ids[i] = uint32(v)
	}
	return ids, nil
}
