package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

type FlowFile struct{ ent.Schema }

func (FlowFile) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "flow_files", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("流水附件表"),
	}
}

func (FlowFile) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{}, mixin.TimeAt{}} }

func (FlowFile) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("flow_id").Optional().Nillable(),
		field.Uint32("creator_id").Optional().Nillable(),
		field.Int64("create_time").Optional().Nillable(),
		field.String("content_type").MaxLen(32).Optional().Nillable(),
		field.Int64("size").Optional().Nillable(),
		field.String("original_name").MaxLen(512).Optional().Nillable(),
		field.String("object_key").MaxLen(256).Optional().Nillable(),
	}
}

func (FlowFile) Indexes() []ent.Index {
	return []ent.Index{index.Fields("flow_id"), index.Fields("creator_id")}
}
