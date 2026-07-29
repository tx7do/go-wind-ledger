package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"

	"github.com/tx7do/go-crud/entgo/mixin"
)

// BookTemplate 账本模板
type BookTemplate struct{ ent.Schema }

func (BookTemplate) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "book_templates", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("账本模板表"),
	}
}

func (BookTemplate) Mixin() []ent.Mixin {
	return []ent.Mixin{
		mixin.AutoIncrementId{},
		mixin.TimeAt{},
	}
}

func (BookTemplate) Fields() []ent.Field {
	return []ent.Field{
		field.String("name").Comment("模板名称").MaxLen(64).NotEmpty().Optional().Nillable(),
		field.String("locale").Comment("区域语言").MaxLen(16).Optional().Nillable(),
		field.String("thumbnail").Comment("缩略图").MaxLen(512).Optional().Nillable(),
	}
}
