package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type LoginAuditLog struct{ ent.Schema }
func (LoginAuditLog) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"login_audit_logs",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true)} }
func (LoginAuditLog) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{}} }
func (LoginAuditLog) Fields() []ent.Field { return []ent.Field{field.Uint32("user_id").Optional().Nillable(),field.String("username").MaxLen(64).Optional().Nillable(),field.String("result").MaxLen(64).Optional().Nillable(),field.Time("logged_at").Optional().Nillable()} }
func (LoginAuditLog) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id"),index.Fields("user_id"),index.Fields("logged_at")} }
