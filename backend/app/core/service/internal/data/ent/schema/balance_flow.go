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

type BalanceFlow struct{ ent.Schema }

func (BalanceFlow) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "balance_flows", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("余额流水表"),
	}
}

func (BalanceFlow) Mixin() []ent.Mixin {
	return []ent.Mixin{mixin.AutoIncrementId{}, mixin.TenantID[uint32]{}, mixin.TimeAt{}, mixin.OperatorID{}}
}

func (BalanceFlow) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("book_id").Optional().Nillable(),
		field.Enum("type").NamedValues("FlowTypeExpense", "FLOW_TYPE_EXPENSE", "FlowTypeIncome", "FLOW_TYPE_INCOME", "FlowTypeTransfer", "FLOW_TYPE_TRANSFER", "FlowTypeAdjust", "FLOW_TYPE_ADJUST").Optional().Nillable(),
		field.Float("amount").SchemaType(map[string]string{dialect.Postgres: "numeric(15,2)", dialect.MySQL: "decimal(15,2)"}).Optional().Nillable(),
		field.Float("converted_amount").SchemaType(map[string]string{dialect.Postgres: "numeric(15,2)", dialect.MySQL: "decimal(15,2)"}).Optional().Nillable(),
		field.Uint32("account_id").Optional().Nillable(),
		field.Uint32("to_account_id").Optional().Nillable(),
		field.Uint32("payee_id").Optional().Nillable(),
		field.Uint32("creator_id").Optional().Nillable(),
		field.Int64("create_time").Optional().Nillable(),
		field.String("title").MaxLen(32).Optional().Nillable(),
		field.String("notes").MaxLen(1024).Optional().Nillable(),
		field.Bool("confirm").Default(false).Optional().Nillable(),
		field.Bool("include").Default(true).Optional().Nillable(),
		field.Int64("insert_at").Immutable().Optional().Nillable(),
	}
}

func (BalanceFlow) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("tenant_id"), index.Fields("book_id"), index.Fields("type"),
		index.Fields("account_id"), index.Fields("creator_id"), index.Fields("create_time"),
		index.Fields("book_id", "create_time").StorageKey("idx_flow_book_time"),
		index.Fields("book_id", "type").StorageKey("idx_flow_book_type"),
	}
}
