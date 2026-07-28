package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

type PermissionGroup struct{ ent.Schema }

func (PermissionGroup) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "sys_permission_groups", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("权限组表"),
	}
}

func (PermissionGroup) Mixin() []ent.Mixin {
	return []ent.Mixin{
		mixin.AutoIncrementId{}, mixin.TimeAt{}, mixin.OperatorID{}, mixin.TenantID[uint32]{},
	}
}

func (PermissionGroup) Fields() []ent.Field {
	return []ent.Field{
		field.String("name").MaxLen(64).Optional().Nillable(),
		field.String("code").MaxLen(32).Optional().Nillable(),
		field.String("module").MaxLen(64).Optional().Nillable(),
		field.Enum("status").NamedValues("StatusActive", "STATUS_ACTIVE", "StatusInactive", "STATUS_INACTIVE").Default("STATUS_ACTIVE").Optional().Nillable(),
		field.Uint32("parent_id").Optional().Nillable(),
		field.Uint32("permission_id").Optional().Nillable(),
		field.Uint32("sort_order").Default(0).Optional().Nillable(),
		field.String("description").MaxLen(256).Optional().Nillable(),
		field.String("path").MaxLen(512).Optional().Nillable(),
		field.Uint32("target_id").Optional().Nillable(),
	}
}

func (PermissionGroup) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("permission_id"),
		index.Fields("parent_id"),
		index.Fields("module"),
	}
}
