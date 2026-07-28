package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type DataAccessAuditLog struct{ ent.Schema }
func (DataAccessAuditLog) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"data_access_audit_logs",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true)} }
func (DataAccessAuditLog) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{}} }
func (DataAccessAuditLog) Fields() []ent.Field { return []ent.Field{field.Uint32("operator_id").Optional().Nillable(),field.String("resource").MaxLen(256).Optional().Nillable(),field.String("action").MaxLen(64).Optional().Nillable(),field.Uint32("user_id").Optional().Nillable(),
		field.String("username").MaxLen(64).Optional().Nillable(),
		field.Enum("access_type").NamedValues("AccessTypeRead","ACCESS_TYPE_READ","AccessTypeWrite","ACCESS_TYPE_WRITE","AccessTypeDelete","ACCESS_TYPE_DELETE").Default("ACCESS_TYPE_READ").Optional().Nillable(),
		field.Enum("sensitive_level").NamedValues("SensitiveLevelLow","SENSITIVE_LEVEL_LOW","SensitiveLevelMedium","SENSITIVE_LEVEL_MEDIUM","SensitiveLevelHigh","SENSITIVE_LEVEL_HIGH").Default("SENSITIVE_LEVEL_LOW").Optional().Nillable(),
		field.String("ip_address").MaxLen(45).Optional().Nillable(),
		field.String("data_source").MaxLen(64).Optional().Nillable(),
		field.Time("accessed_at").Optional().Nillable()} }
func (DataAccessAuditLog) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id"),index.Fields("operator_id"),index.Fields("accessed_at")} }
