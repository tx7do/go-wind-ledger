package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type Api struct{ ent.Schema }
func (Api) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"apis",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true)} }
func (Api) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{},mixin.TenantID[uint32]{}} }
func (Api) Fields() []ent.Field { return []ent.Field{field.String("path").MaxLen(256).Optional().Nillable(),field.String("method").MaxLen(16).Optional().Nillable(),field.String("description").MaxLen(256).Optional().Nillable(),
		field.Enum("scope").NamedValues("ScopeAdmin","ADMIN","ScopeApp","APP").Default("ADMIN").Optional().Nillable()} }
func (Api) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id"),index.Fields("path","method")} }
