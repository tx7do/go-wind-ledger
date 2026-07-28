package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type OperationAuditLog struct{ ent.Schema }
func (OperationAuditLog) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"operation_audit_logs",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true)} }
func (OperationAuditLog) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{}} }
func (OperationAuditLog) Fields() []ent.Field { return []ent.Field{field.Uint32("operator_id").Optional().Nillable(),field.String("action").MaxLen(128).Optional().Nillable(),field.JSON("old_data",map[string]interface{}{}).Optional(),field.JSON("new_data",map[string]interface{}{}).Optional(),field.Time("operated_at").Optional().Nillable()} }
func (OperationAuditLog) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id"),index.Fields("operator_id"),index.Fields("operated_at")} }
