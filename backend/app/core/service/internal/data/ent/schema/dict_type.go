package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type DictType struct{ ent.Schema }
func (DictType) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_dict_types",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("字典类型表")} }
func (DictType) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{},mixin.Remark{}} }
func (DictType) Fields() []ent.Field {
	return []ent.Field{
		field.String("code").Comment("字典代码").MaxLen(32).Optional().Nillable(),
		field.String("name").Comment("字典名称").MaxLen(32).Optional().Nillable(),
	}
}
func (DictType) Indexes() []ent.Index { return []ent.Index{index.Fields("code").Unique()} }
