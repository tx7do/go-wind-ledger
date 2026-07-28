package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type ApiAuditLog struct{ ent.Schema }
func (ApiAuditLog) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"api_audit_logs",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true)} }
func (ApiAuditLog) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{}} }
func (ApiAuditLog) Fields() []ent.Field { return []ent.Field{field.Uint32("operator_id").Optional().Nillable(),field.String("operator_name").MaxLen(64).Optional().Nillable(),field.String("path").MaxLen(256).Optional().Nillable(),field.String("method").MaxLen(16).Optional().Nillable(),field.String("detail").MaxLen(4096).Optional().Nillable(),field.Uint32("user_id").Optional().Nillable(),
		field.String("username").MaxLen(64).Optional().Nillable(),
		field.String("ip_address").MaxLen(45).Optional().Nillable(),
		field.String("device_info").MaxLen(256).Optional().Nillable(),
		field.Time("operated_at").Optional().Nillable()} }
func (ApiAuditLog) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id"),index.Fields("operator_id"),index.Fields("operated_at")} }
