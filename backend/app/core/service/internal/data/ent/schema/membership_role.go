package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type MembershipRole struct{ ent.Schema }
func (MembershipRole) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_membership_roles",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("成员角色关联表")} }
func (MembershipRole) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{}} }
func (MembershipRole) Fields() []ent.Field { return []ent.Field{field.Uint32("membership_id").Optional().Nillable(),field.Uint32("role_id").Optional().Nillable()} }
func (MembershipRole) Indexes() []ent.Index { return []ent.Index{index.Fields("membership_id"),index.Fields("role_id"),index.Fields("membership_id","role_id").Unique()} }
