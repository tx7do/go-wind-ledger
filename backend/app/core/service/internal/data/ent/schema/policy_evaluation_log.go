package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type PolicyEvaluationLog struct{ ent.Schema }
func (PolicyEvaluationLog) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"policy_evaluation_logs",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true)} }
func (PolicyEvaluationLog) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{}} }
func (PolicyEvaluationLog) Fields() []ent.Field { return []ent.Field{field.Uint32("operator_id").Optional().Nillable(),field.String("policy").MaxLen(256).Optional().Nillable(),field.String("result").MaxLen(64).Optional().Nillable(),field.Time("evaluated_at").Optional().Nillable()} }
func (PolicyEvaluationLog) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id"),index.Fields("operator_id"),index.Fields("evaluated_at")} }
