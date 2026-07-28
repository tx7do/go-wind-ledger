package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

type Payee struct{ ent.Schema }

func (Payee) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "payees", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("收款人表"),
	}
}

func (Payee) Mixin() []ent.Mixin {
	return []ent.Mixin{mixin.AutoIncrementId{}, mixin.TenantID[uint32]{}, mixin.TimeAt{}, mixin.OperatorID{}, mixin.SortOrder{}}
}

func (Payee) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("book_id").Immutable().Optional().Nillable(),
		field.String("name").MaxLen(64).NotEmpty().Optional().Nillable(),
		field.String("notes").MaxLen(1024).Optional().Nillable(),
		field.Bool("enable").Default(true).Optional().Nillable(),
		field.Bool("can_expense").Default(true).Optional().Nillable(),
		field.Bool("can_income").Default(true).Optional().Nillable(),
	}
}

func (Payee) Indexes() []ent.Index {
	return []ent.Index{index.Fields("tenant_id", "name").Unique().StorageKey("idx_payee_tenant_name"), index.Fields("book_id")}
}
