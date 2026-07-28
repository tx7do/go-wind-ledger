package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type Membership struct{ ent.Schema }
func (Membership) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_memberships",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("成员关系表")} }
func (Membership) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{},mixin.TenantID[uint32]{}} }
func (Membership) Fields() []ent.Field { return []ent.Field{
		field.Uint32("user_id").Optional().Nillable(),
		field.Enum("status").NamedValues("MembershipStatusActive","MEMBERSHIP_STATUS_ACTIVE","MembershipStatusSuspended","MEMBERSHIP_STATUS_SUSPENDED","MembershipStatusExpired","MEMBERSHIP_STATUS_EXPIRED").Default("MEMBERSHIP_STATUS_ACTIVE").Optional().Nillable(),
		field.Time("start_at").Optional().Nillable(),
		field.Time("end_at").Optional().Nillable(),
	} }
func (Membership) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id"),index.Fields("user_id"),index.Fields("tenant_id","user_id").Unique().StorageKey("idx_membership_tenant_user")} }
