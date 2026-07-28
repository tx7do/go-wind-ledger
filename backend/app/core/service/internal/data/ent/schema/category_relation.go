package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

type CategoryRelation struct{ ent.Schema }

func (CategoryRelation) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "category_relations", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("类别关系表"),
	}
}

func (CategoryRelation) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{}} }

func (CategoryRelation) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("category_id").Optional().Nillable(),
		field.Uint32("balance_flow_id").Optional().Nillable(),
		field.Float("amount").SchemaType(map[string]string{dialect.Postgres: "numeric(15,2)", dialect.MySQL: "decimal(15,2)"}).Optional().Nillable(),
		field.Float("converted_amount").SchemaType(map[string]string{dialect.Postgres: "numeric(15,2)", dialect.MySQL: "decimal(15,2)"}).Optional().Nillable(),
	}
}

func (CategoryRelation) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("balance_flow_id"), index.Fields("category_id"),
		index.Fields("balance_flow_id", "category_id").Unique().StorageKey("idx_cat_rel_flow_cat"),
	}
}
