package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type Menu struct{ ent.Schema }
func (Menu) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_menus",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("菜单表")} }
func (Menu) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{},mixin.Tree[Menu]{},mixin.Remark{},mixin.SwitchStatus{}} }
func (Menu) Fields() []ent.Field { return []ent.Field{field.String("name").MaxLen(32).Optional().Nillable(),field.String("path").MaxLen(256).Optional().Nillable(),field.String("icon").MaxLen(64).Optional().Nillable(),field.String("component").MaxLen(256).Optional().Nillable(),field.Uint32("sort_order").Default(0).Optional().Nillable()} }
func (Menu) Indexes() []ent.Index { return []ent.Index{index.Fields("parent_id")} }
