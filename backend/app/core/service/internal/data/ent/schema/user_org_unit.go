package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type UserOrgUnit struct{ ent.Schema }
func (UserOrgUnit) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_user_org_units",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("用户组织单元关联表")} }
func (UserOrgUnit) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{},mixin.SwitchStatus{},mixin.OperatorID{}} }
func (UserOrgUnit) Fields() []ent.Field {
	return []ent.Field{
		field.Bool("is_primary").Default(false).Optional().Nillable(),
		field.Time("start_at").Optional().Nillable(),
		field.Time("end_at").Optional().Nillable(),
		field.Uint32("user_id").Comment("用户ID").Optional().Nillable(),
		field.Uint32("org_unit_id").Comment("组织单元ID").Optional().Nillable(),
	}
}
func (UserOrgUnit) Indexes() []ent.Index { return []ent.Index{index.Fields("user_id"),index.Fields("org_unit_id"),index.Fields("user_id","org_unit_id").Unique()} }
