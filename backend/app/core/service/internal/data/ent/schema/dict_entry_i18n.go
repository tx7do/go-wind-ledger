package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type DictEntryI18n struct{ ent.Schema }
func (DictEntryI18n) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_dict_entry_i18n",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("字典项国际化表")} }
func (DictEntryI18n) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.TenantID[uint32]{},mixin.OperatorID{}} }
func (DictEntryI18n) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("dict_entry_id").Comment("字典项ID").Optional().Nillable(),
		field.String("language_code").Comment("语言代码").MaxLen(16).Optional().Nillable(),
		field.String("name").Comment("名称").MaxLen(64).Optional().Nillable(),
	}
}
func (DictEntryI18n) Indexes() []ent.Index { return []ent.Index{index.Fields("dict_entry_id"),index.Fields("dict_entry_id","language_code").Unique()} }
