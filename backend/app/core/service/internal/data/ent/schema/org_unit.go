package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

type OrgUnit struct{ ent.Schema }

func (OrgUnit) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "sys_org_units", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("组织单元表"),
	}
}

func (OrgUnit) Mixin() []ent.Mixin {
	return []ent.Mixin{
		mixin.AutoIncrementId{}, mixin.TimeAt{}, mixin.OperatorID{},
		mixin.SwitchStatus{}, mixin.SortOrder{}, mixin.TenantID[uint32]{},
		mixin.Remark{}, mixin.Description{},
		mixin.Tree[OrgUnit]{}, mixin.TreePath{},
	}
}

func (OrgUnit) Fields() []ent.Field {
	return []ent.Field{
		field.String("code").MaxLen(32).Optional().Nillable(),
		field.String("name").MaxLen(64).Optional().Nillable(),
		field.String("type").MaxLen(32).Optional().Nillable(),
		field.Bool("is_legal_entity").Default(false).Optional().Nillable(),
		field.String("external_id").MaxLen(64).Optional().Nillable(),
		field.Uint32("legal_entity_org_id").Optional().Nillable(),
		field.String("tax_id").MaxLen(64).Optional().Nillable(),
		field.String("registration_number").MaxLen(64).Optional().Nillable(),
		field.Uint32("leader_id").Optional().Nillable(),
		field.Uint32("contact_user_id").Optional().Nillable(),
		field.Time("start_at").Optional().Nillable(),
		field.Time("end_at").Optional().Nillable(),
		field.String("address").MaxLen(256).Optional().Nillable(),
		field.String("phone").MaxLen(32).Optional().Nillable(),
		field.String("email").MaxLen(64).Optional().Nillable(),
		field.String("website").MaxLen(128).Optional().Nillable(),
		field.String("timezone").MaxLen(64).Optional().Nillable(),
		field.String("region").MaxLen(64).Optional().Nillable(),
		field.String("country").MaxLen(64).Optional().Nillable(),
		field.String("city").MaxLen(64).Optional().Nillable(),
		field.String("postal_code").MaxLen(32).Optional().Nillable(),
		field.Float("latitude").Optional().Nillable(),
		field.Float("longitude").Optional().Nillable(),
		field.String("logo").MaxLen(256).Optional().Nillable(),
	}
}

func (OrgUnit) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("tenant_id"), index.Fields("parent_id"), index.Fields("code"),
	}
}
