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

type Account struct{ ent.Schema }

func (Account) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "accounts", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("财务账户表"),
	}
}

func (Account) Mixin() []ent.Mixin {
	return []ent.Mixin{mixin.AutoIncrementId{}, mixin.TenantID[uint32]{}, mixin.TimeAt{}, mixin.OperatorID{}, mixin.SortOrder{}}
}

func (Account) Fields() []ent.Field {
	return []ent.Field{
		field.String("name").MaxLen(64).NotEmpty().Optional().Nillable(),
		field.Enum("type").NamedValues("AccountTypeChecking", "ACCOUNT_TYPE_CHECKING", "AccountTypeCredit", "ACCOUNT_TYPE_CREDIT", "AccountTypeAsset", "ACCOUNT_TYPE_ASSET", "AccountTypeDebt", "ACCOUNT_TYPE_DEBT").Optional().Nillable(),
		field.Float("balance").SchemaType(map[string]string{dialect.Postgres: "numeric(20,2)", dialect.MySQL: "decimal(20,2)"}).Default(0).Optional().Nillable(),
		field.Float("initial_balance").SchemaType(map[string]string{dialect.Postgres: "numeric(20,2)", dialect.MySQL: "decimal(20,2)"}).Default(0).Optional().Nillable(),
		field.Float("credit_limit").SchemaType(map[string]string{dialect.Postgres: "numeric(20,2)", dialect.MySQL: "decimal(20,2)"}).Default(0).Optional().Nillable(),
		field.Int32("bill_day").Optional().Nillable(),
		field.Float("apr").Optional().Nillable(),
		field.String("currency_code").MaxLen(8).NotEmpty().Optional().Nillable(),
		field.String("no").MaxLen(32).Optional().Nillable(),
		field.Bool("include").Default(true).Optional().Nillable(),
		field.Bool("can_expense").Default(true).Optional().Nillable(),
		field.Bool("can_income").Default(true).Optional().Nillable(),
		field.Bool("can_transfer_from").Default(true).Optional().Nillable(),
		field.Bool("can_transfer_to").Default(true).Optional().Nillable(),
		field.String("notes").MaxLen(1024).Optional().Nillable(),
		field.Bool("enable").Default(true).Optional().Nillable(),
	}
}

func (Account) Indexes() []ent.Index {
	return []ent.Index{index.Fields("tenant_id", "name").Unique().StorageKey("idx_account_tenant_name"), index.Fields("tenant_id"), index.Fields("type"), index.Fields("enable")}
}
