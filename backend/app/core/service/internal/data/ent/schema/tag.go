package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

type Tag struct{ ent.Schema }

func (Tag) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "tags", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("标签表"),
	}
}

func (Tag) Mixin() []ent.Mixin {
	return []ent.Mixin{mixin.AutoIncrementId{}, mixin.TenantID[uint32]{}, mixin.TimeAt{}, mixin.OperatorID{}, mixin.SortOrder{}, mixin.TreePath{}, mixin.Tree[Tag]{}}
}

func (Tag) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("book_id").Immutable().Optional().Nillable(),
		field.String("name").MaxLen(64).NotEmpty().Optional().Nillable(),
		field.String("notes").MaxLen(4096).Optional().Nillable(),
		field.Bool("enable").Default(true).Optional().Nillable(),
		field.Bool("can_expense").Default(true).Optional().Nillable(),
		field.Bool("can_income").Default(true).Optional().Nillable(),
		field.Bool("can_transfer").Default(true).Optional().Nillable(),
		field.Int32("depth").Default(0).Optional().Nillable(),
	}
}

func (Tag) Indexes() []ent.Index {
	return []ent.Index{index.Fields("tenant_id"), index.Fields("book_id"), index.Fields("parent_id")}
}
