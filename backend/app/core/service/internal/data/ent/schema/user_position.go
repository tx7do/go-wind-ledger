package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type UserPosition struct{ ent.Schema }
func (UserPosition) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_user_positions",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("用户岗位关联表")} }
func (UserPosition) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{},mixin.OperatorID{}} }
func (UserPosition) Fields() []ent.Field {
	return []ent.Field{
		field.Enum("status").NamedValues("Probation","PROBATION","Active","ACTIVE","Leave","LEAVE","Resigned","RESIGNED","Terminated","TERMINATED","Expired","EXPIRED").Default("ACTIVE").Optional().Nillable(),
		field.Bool("is_primary").Default(false).Optional().Nillable(),
		field.Time("start_at").Optional().Nillable(),
		field.Time("end_at").Optional().Nillable(),
		field.Uint32("user_id").Comment("用户ID").Optional().Nillable(),
		field.Uint32("position_id").Comment("岗位ID").Optional().Nillable(),
	}
}
func (UserPosition) Indexes() []ent.Index { return []ent.Index{index.Fields("user_id"),index.Fields("position_id"),index.Fields("user_id","position_id").Unique()} }
