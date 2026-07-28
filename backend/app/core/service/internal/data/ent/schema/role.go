package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type Role struct{ ent.Schema }
func (Role) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_roles",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("角色表")} }
func (Role) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{},mixin.Remark{},mixin.Description{},mixin.SortOrder{},mixin.TenantID[uint32]{},mixin.SwitchStatus{}} }
func (Role) Fields() []ent.Field {
	return []ent.Field{
		field.String("code").Comment("角色代码").MaxLen(32).Optional().Nillable(),
		field.String("name").Comment("角色名称").MaxLen(32).Optional().Nillable(),
		field.Bool("is_system").Comment("系统角色").Default(false).Optional().Nillable(),
	}
}
func (Role) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id","code").Unique(),index.Fields("tenant_id")} }
