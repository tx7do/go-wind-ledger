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

type TagRelation struct{ ent.Schema }

func (TagRelation) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "tag_relations", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("标签关系表"),
	}
}

func (TagRelation) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{}} }

func (TagRelation) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("tag_id").Optional().Nillable(),
		field.Uint32("balance_flow_id").Optional().Nillable(),
		field.Float("amount").SchemaType(map[string]string{dialect.Postgres: "numeric(15,2)", dialect.MySQL: "decimal(15,2)"}).Optional().Nillable(),
		field.Float("converted_amount").SchemaType(map[string]string{dialect.Postgres: "numeric(15,2)", dialect.MySQL: "decimal(15,2)"}).Optional().Nillable(),
	}
}

func (TagRelation) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("balance_flow_id"), index.Fields("tag_id"),
		index.Fields("balance_flow_id", "tag_id").Unique().StorageKey("idx_tag_rel_flow_tag"),
	}
}
