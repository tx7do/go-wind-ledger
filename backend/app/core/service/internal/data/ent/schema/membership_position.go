package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type MembershipPosition struct{ ent.Schema }
func (MembershipPosition) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_membership_positions",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("成员岗位关联表")} }
func (MembershipPosition) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{}} }
func (MembershipPosition) Fields() []ent.Field { return []ent.Field{field.Uint32("membership_id").Optional().Nillable(),field.Uint32("position_id").Optional().Nillable()} }
func (MembershipPosition) Indexes() []ent.Index { return []ent.Index{index.Fields("membership_id"),index.Fields("position_id"),index.Fields("membership_id","position_id").Unique()} }
