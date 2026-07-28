package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

type Position struct{ ent.Schema }

func (Position) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "sys_positions", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("岗位表"),
	}
}

func (Position) Mixin() []ent.Mixin {
	return []ent.Mixin{
		mixin.AutoIncrementId{}, mixin.TimeAt{}, mixin.OperatorID{},
		mixin.SwitchStatus{}, mixin.SortOrder{}, mixin.TenantID[uint32]{}, mixin.Remark{},
	}
}

func (Position) Fields() []ent.Field {
	return []ent.Field{
		field.String("job_grade").MaxLen(32).Optional().Nillable(),
		field.String("job_family").MaxLen(64).Optional().Nillable(),
		field.String("type").MaxLen(32).Optional().Nillable(),
		field.String("code").Comment("岗位代码").MaxLen(32).Optional().Nillable(),
		field.Uint32("reports_to_position_id").Optional().Nillable(),
		field.Bool("is_template").Default(false).Optional().Nillable(),
		field.Uint32("org_unit_id").Optional().Nillable(),
		field.String("name").Comment("岗位名称").MaxLen(64).Optional().Nillable(),
	}
}

func (Position) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("tenant_id"),
		index.Fields("tenant_id", "code").Unique(),
	}
}
