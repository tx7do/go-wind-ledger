package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

// Budget 预算
type Budget struct{ ent.Schema }

func (Budget) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "budgets", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("预算表"),
	}
}

func (Budget) Mixin() []ent.Mixin {
	return []ent.Mixin{
		mixin.AutoIncrementId{},
		mixin.TenantID[uint32]{},
		mixin.TimeAt{},
		mixin.OperatorID{},
	}
}

func (Budget) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("book_id").Comment("所属账本ID").Optional().Nillable(),
		field.String("name").Comment("预算名称").MaxLen(64).Optional().Nillable(),
		field.Enum("period").
			Comment("预算周期").
			NamedValues(
				"BudgetPeriodMonthly", "BUDGET_PERIOD_MONTHLY",
				"BudgetPeriodYearly", "BUDGET_PERIOD_YEARLY",
				"BudgetPeriodQuarterly", "BUDGET_PERIOD_QUARTERLY",
				"BudgetPeriodWeekly", "BUDGET_PERIOD_WEEKLY",
			).Optional().Nillable(),
		field.Float("amount").
			SchemaType(map[string]string{
				"postgres": "numeric(20,2)",
				"mysql":    "decimal(20,2)",
			}).
			Comment("预算金额").
			Default(0).
			Optional().Nillable(),
		field.Float("used_amount").
			SchemaType(map[string]string{
				"postgres": "numeric(20,2)",
				"mysql":    "decimal(20,2)",
			}).
			Comment("已用金额（缓存值，定期从流水汇总更新）").
			Default(0).
			Optional().Nillable(),
		field.Uint32("category_id").Comment("关联分类ID（可选，按分类预算）").Optional().Nillable(),
		field.Uint32("account_id").Comment("关联账户ID（可选，按账户预算）").Optional().Nillable(),
		field.Int64("start_date").Comment("预算周期开始时间（epoch 毫秒）").Optional().Nillable(),
		field.Int64("end_date").Comment("预算周期结束时间（epoch 毫秒）").Optional().Nillable(),
		field.Bool("enable").Comment("是否启用").Default(true).Optional().Nillable(),
		field.Bool("notify").Comment("超额通知").Default(true).Optional().Nillable(),
		field.String("notes").Comment("备注").MaxLen(1024).Optional().Nillable(),
	}
}

func (Budget) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("tenant_id"),
		index.Fields("book_id"),
		index.Fields("category_id"),
		index.Fields("period"),
		index.Fields("book_id", "category_id").StorageKey("idx_budget_book_cat"),
	}
}
