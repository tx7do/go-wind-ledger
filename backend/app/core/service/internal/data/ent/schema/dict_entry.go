package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type DictEntry struct{ ent.Schema }
func (DictEntry) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_dict_entries",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("字典项表")} }
func (DictEntry) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{},mixin.TenantID[uint32]{},mixin.Remark{},mixin.SortOrder{}} }
func (DictEntry) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("dict_type_id").Comment("字典类型ID").Optional().Nillable(),
		field.String("code").Comment("项代码").MaxLen(32).Optional().Nillable(),
		field.String("name").Comment("项名称").MaxLen(32).Optional().Nillable(),
		field.String("value").Comment("项值").MaxLen(128).Optional().Nillable(),
	}
}
func (DictEntry) Indexes() []ent.Index { return []ent.Index{index.Fields("dict_type_id"),index.Fields("dict_type_id","code").Unique()} }
