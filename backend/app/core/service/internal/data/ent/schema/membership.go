package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

// Membership 成员关系（用户-租户关联，含邀请/接受工作流）
type Membership struct{ ent.Schema }

func (Membership) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "sys_memberships", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("成员关系表"),
	}
}

func (Membership) Mixin() []ent.Mixin {
	return []ent.Mixin{
		mixin.AutoIncrementId{},
		mixin.TimeAt{},
		mixin.OperatorID{},
		mixin.TenantID[uint32]{},
	}
}

func (Membership) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("user_id").Comment("用户ID").Optional().Nillable(),
		field.Bool("is_primary").Comment("是否主身份").Default(false).Optional().Nillable(),
		field.Enum("status").
			Comment("成员状态").
			NamedValues(
				"MembershipStatusDisabled", "MEMBERSHIP_STATUS_DISABLED",
				"MembershipStatusActive", "MEMBERSHIP_STATUS_ACTIVE",
				"MembershipStatusPending", "MEMBERSHIP_STATUS_PENDING",
				"MembershipStatusInvited", "MEMBERSHIP_STATUS_INVITED",
				"MembershipStatusExpired", "MEMBERSHIP_STATUS_EXPIRED",
				"MembershipStatusRejected", "MEMBERSHIP_STATUS_REJECTED",
			).
			Default("MEMBERSHIP_STATUS_ACTIVE").
			Optional().
			Nillable(),
		field.Uint32("role_id").Comment("角色ID").Optional().Nillable(),
		field.Time("joined_at").Comment("加入时间").Optional().Nillable(),
		field.Time("start_at").Comment("生效时间").Optional().Nillable(),
		field.Time("end_at").Comment("失效时间").Optional().Nillable(),
	}
}

func (Membership) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("tenant_id"),
		index.Fields("user_id"),
		index.Fields("status"),
		index.Fields("tenant_id", "user_id").Unique().StorageKey("idx_membership_tenant_user"),
	}
}
