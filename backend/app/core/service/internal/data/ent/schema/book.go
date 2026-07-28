package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

// Book 账本
type Book struct{ ent.Schema }

func (Book) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "books", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("账本表"),
	}
}

func (Book) Mixin() []ent.Mixin {
	return []ent.Mixin{mixin.AutoIncrementId{}, mixin.TenantID[uint32]{}, mixin.TimeAt{}, mixin.OperatorID{}, mixin.SortOrder{}}
}

func (Book) Fields() []ent.Field {
	return []ent.Field{
		field.String("name").Comment("账本名称").MaxLen(64).NotEmpty().Optional().Nillable(),
		field.String("default_currency_code").Comment("默认币种代码").MaxLen(8).NotEmpty().Optional().Nillable(),
		field.String("notes").Comment("备注").MaxLen(1024).Optional().Nillable(),
		field.Bool("enable").Comment("是否启用").Default(true).Optional().Nillable(),
		field.Int64("export_at").Comment("上次导出时间").Optional().Nillable(),
		field.Uint32("default_expense_account_id").Optional().Nillable(),
		field.Uint32("default_income_account_id").Optional().Nillable(),
		field.Uint32("default_transfer_from_account_id").Optional().Nillable(),
		field.Uint32("default_transfer_to_account_id").Optional().Nillable(),
		field.Uint32("default_expense_category_id").Optional().Nillable(),
		field.Uint32("default_income_category_id").Optional().Nillable(),
	}
}

func (Book) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("tenant_id", "name").Unique().StorageKey("idx_book_tenant_name"),
		index.Fields("tenant_id"),
	}
}
