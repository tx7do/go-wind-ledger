package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type LoginPolicy struct{ ent.Schema }
func (LoginPolicy) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_login_policies",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("登录策略表")} }
func (LoginPolicy) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{},mixin.TenantID[uint32]{},mixin.Remark{}} }
func (LoginPolicy) Fields() []ent.Field { return []ent.Field{field.String("name").MaxLen(64).Optional().Nillable(),field.Enum("type").NamedValues("PolicyTypeIpBlacklist","POLICY_TYPE_IP_BLACKLIST","PolicyTypeMacWhitelist","POLICY_TYPE_MAC_WHITELIST").Optional().Nillable(),field.String("config").MaxLen(2048).Optional().Nillable(),field.Enum("method").NamedValues("MethodPassword","METHOD_PASSWORD","MethodOauth","METHOD_OAUTH","MethodSms","METHOD_SMS").Default("METHOD_PASSWORD").Optional().Nillable(),
		field.Bool("enable").Default(true).Optional().Nillable()} }
func (LoginPolicy) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id")} }
