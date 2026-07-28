package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type UserCredential struct{ ent.Schema }
func (UserCredential) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_user_credentials",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("用户凭证表")} }
func (UserCredential) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{},mixin.OperatorID{}} }
func (UserCredential) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("user_id").Comment("用户ID").Optional().Nillable(),
		field.String("identifier").MaxLen(128).Optional().Nillable(),
		field.String("identity_type").MaxLen(32).Optional().Nillable(),
		field.String("credential_type").Comment("凭证类型").MaxLen(32).Optional().Nillable(),
		field.String("credential").Comment("凭证值").MaxLen(128).Optional().Nillable(),
		field.String("provider_account_id").MaxLen(128).Optional().Nillable(),
		field.String("provider").MaxLen(64).Optional().Nillable(),
		field.String("extra_info").MaxLen(512).Optional().Nillable(),
		field.Bool("is_primary").Default(false).Optional().Nillable(),
		field.Enum("status").NamedValues("StatusActive","STATUS_ACTIVE","StatusInactive","STATUS_INACTIVE").Default("STATUS_ACTIVE").Optional().Nillable(),
		field.Bool("verified").Comment("已验证").Default(false).Optional().Nillable(),
	}
}
func (UserCredential) Indexes() []ent.Index { return []ent.Index{index.Fields("user_id"),index.Fields("credential_type","credential").Unique()} }
