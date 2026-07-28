package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type MembershipOrgUnit struct{ ent.Schema }
func (MembershipOrgUnit) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_membership_org_units",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("成员组织关联表")} }
func (MembershipOrgUnit) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{}} }
func (MembershipOrgUnit) Fields() []ent.Field { return []ent.Field{field.Uint32("membership_id").Optional().Nillable(),field.Uint32("org_unit_id").Optional().Nillable()} }
func (MembershipOrgUnit) Indexes() []ent.Index { return []ent.Index{index.Fields("membership_id"),index.Fields("org_unit_id"),index.Fields("membership_id","org_unit_id").Unique()} }
