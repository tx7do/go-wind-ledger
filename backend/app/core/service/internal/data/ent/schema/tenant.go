package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

type Tenant struct{ ent.Schema }

func (Tenant) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "sys_tenants", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("租户表"),
	}
}

func (Tenant) Mixin() []ent.Mixin {
	return []ent.Mixin{
		mixin.AutoIncrementId{},
		mixin.TimeAt{},
		mixin.OperatorID{},
		mixin.Remark{},
	}
}

func (Tenant) Fields() []ent.Field {
	return []ent.Field{
		field.String("name").Comment("租户名称").MaxLen(64).Optional().Nillable(),
		field.String("code").MaxLen(32).Optional().Nillable(),
		field.String("domain").MaxLen(128).Optional().Nillable(),
		field.String("logo_url").MaxLen(256).Optional().Nillable(),
		field.String("logo").Optional().Nillable(),
		field.String("website").Optional().Nillable(),
		field.String("industry").MaxLen(64).Optional().Nillable(),
		field.Uint32("admin_user_id").Optional().Nillable(),
		field.String("contact_name").Optional().Nillable(),
		field.String("contact_email").Optional().Nillable(),
		field.String("contact_phone").Optional().Nillable(),
		field.Enum("status").Comment("租户状态").NamedValues("TenantStatusActive", "TENANT_STATUS_ACTIVE", "TenantStatusSuspended", "TENANT_STATUS_SUSPENDED", "TenantStatusCancelled", "TENANT_STATUS_CANCELLED").Default("TENANT_STATUS_ACTIVE").Optional().Nillable(),
		field.Enum("type").Comment("租户类型").NamedValues("TenantTypePersonal", "TENANT_TYPE_PERSONAL", "TenantTypeEnterprise", "TENANT_TYPE_ENTERPRISE").Default("TENANT_TYPE_PERSONAL").Optional().Nillable(),
		field.Enum("audit_status").NamedValues("AuditStatusPending", "AUDIT_STATUS_PENDING", "AuditStatusApproved", "AUDIT_STATUS_APPROVED", "AuditStatusRejected", "AUDIT_STATUS_REJECTED").Default("AUDIT_STATUS_PENDING").Optional().Nillable(),
		field.String("subscription_plan").MaxLen(64).Optional().Nillable(),
		field.Time("unsubscribe_at").Optional().Nillable(),
		field.Time("subscription_at").Optional().Nillable(),
		field.Time("expired_at").Optional().Nillable(),
		field.String("default_currency_code").MaxLen(8).Default("CNY").Optional().Nillable(),
		field.Uint32("default_book_id").Optional().Nillable(),
	}
}

func (Tenant) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("name").Unique(),
		index.Fields("status"),
	}
}
