package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

type Language struct{ ent.Schema }

func (Language) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "sys_languages", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("语言表"),
	}
}
func (Language) Mixin() []ent.Mixin {
	return []ent.Mixin{mixin.AutoIncrementId{}, mixin.TimeAt{}, mixin.OperatorID{}}
}
func (Language) Fields() []ent.Field {
	return []ent.Field{
		field.String("code").MaxLen(16).Optional().Nillable(),
		field.String("name").MaxLen(32).Optional().Nillable(),
		field.Bool("enable").Default(true).Optional().Nillable(),
	}
}
func (Language) Indexes() []ent.Index {
	return []ent.Index{index.Fields("code").Unique()}
}
