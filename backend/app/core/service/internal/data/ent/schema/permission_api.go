package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type PermissionApi struct{ ent.Schema }
func (PermissionApi) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_permission_apis",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true)} }
func (PermissionApi) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{}} }
func (PermissionApi) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("permission_id").Comment("权限ID").Optional().Nillable(),
		field.Uint32("target_id").Comment("目标ID").Optional().Nillable(),
	}
}
func (PermissionApi) Indexes() []ent.Index { return []ent.Index{index.Fields("permission_id")} }
