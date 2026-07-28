package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type RolePermission struct{ ent.Schema }
func (RolePermission) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_role_permissions",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("角色权限关联表")} }
func (RolePermission) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{},mixin.SwitchStatus{},mixin.OperatorID{}} }
func (RolePermission) Fields() []ent.Field {
	return []ent.Field{
		field.String("effect").MaxLen(32).Default("ALLOW").Optional().Nillable(),
		field.Uint32("role_id").Comment("角色ID").Optional().Nillable(),
		field.Uint32("permission_id").Comment("权限ID").Optional().Nillable(),
	}
}
func (RolePermission) Indexes() []ent.Index { return []ent.Index{index.Fields("role_id"),index.Fields("permission_id"),index.Fields("role_id","permission_id").Unique()} }
