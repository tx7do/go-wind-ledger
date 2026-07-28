package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type UserRole struct{ ent.Schema }
func (UserRole) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_user_roles",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("用户角色关联表")} }
func (UserRole) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{},mixin.SwitchStatus{},mixin.OperatorID{}} }
func (UserRole) Fields() []ent.Field {
	return []ent.Field{
		field.Bool("is_primary").Default(false).Optional().Nillable(),
		field.Time("start_at").Optional().Nillable(),
		field.Time("end_at").Optional().Nillable(),
		field.Uint32("user_id").Comment("用户ID").Optional().Nillable(),
		field.Uint32("role_id").Comment("角色ID").Optional().Nillable(),
	}
}
func (UserRole) Indexes() []ent.Index { return []ent.Index{index.Fields("user_id"),index.Fields("role_id"),index.Fields("user_id","role_id","tenant_id").Unique().StorageKey("idx_user_role_unique")} }
