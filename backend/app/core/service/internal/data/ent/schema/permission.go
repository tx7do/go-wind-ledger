package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type Permission struct{ ent.Schema }
func (Permission) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_permissions",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("权限表")} }
func (Permission) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{},mixin.TenantID[uint32]{},mixin.Remark{}} }
func (Permission) Fields() []ent.Field {
	return []ent.Field{
		field.String("code").Comment("权限代码").MaxLen(64).Optional().Nillable(),
		field.Enum("status").NamedValues("StatusActive","STATUS_ACTIVE","StatusInactive","STATUS_INACTIVE").Default("STATUS_ACTIVE").Optional().Nillable(),
		field.String("description").MaxLen(256).Optional().Nillable(),
		field.Uint32("group_id").Optional().Nillable(),
		field.String("name").Comment("权限名称").MaxLen(64).Optional().Nillable(),
		field.Enum("type").Comment("权限类型").NamedValues("PermissionTypeMenu","PERMISSION_TYPE_MENU","PermissionTypeApi","PERMISSION_TYPE_API","PermissionTypePolicy","PERMISSION_TYPE_POLICY").Optional().Nillable(),
	}
}
func (Permission) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id","code").Unique(),index.Fields("tenant_id")} }
