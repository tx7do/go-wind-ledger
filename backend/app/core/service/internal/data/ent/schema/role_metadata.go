package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type RoleMetadata struct{ ent.Schema }
func (RoleMetadata) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_role_metadata",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("角色元数据表")} }
func (RoleMetadata) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{}} }
func (RoleMetadata) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("role_id").Comment("角色ID").Optional().Nillable(),
		field.String("template_for").MaxLen(64).Optional().Nillable().Optional().Nillable(),
		field.Int32("template_version").Default(1).Optional().Nillable().Default(1).Optional().Nillable(),
		field.Time("last_synced_at").Optional().Nillable(),
		field.Int32("last_synced_version").Default(0).Optional().Nillable(),
		field.Bool("is_template").Default(false).Optional().Nillable(),
		field.String("key").Comment("键").MaxLen(64).Optional().Nillable(),
		field.String("value").Comment("值").MaxLen(256).Optional().Nillable(),
	}
}
func (RoleMetadata) Indexes() []ent.Index { return []ent.Index{index.Fields("role_id"),index.Fields("role_id","key").Unique()} }
