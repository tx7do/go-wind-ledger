package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type Task struct{ ent.Schema }
func (Task) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"sys_tasks",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("任务表")} }
func (Task) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{},mixin.TenantID[uint32]{},mixin.Remark{}} }
func (Task) Fields() []ent.Field { return []ent.Field{field.String("name").MaxLen(64).Optional().Nillable(),field.String("type_name").MaxLen(64).Optional().Nillable(),
		field.String("cron_spec").MaxLen(128).Optional().Nillable(),
		field.String("task_payload").MaxLen(2048).Optional().Nillable(),
		field.JSON("task_options", &map[string]string{}).Optional(),
		field.Enum("type").NamedValues("TaskTypeCron","TASK_TYPE_CRON","TaskTypeOneOff","TASK_TYPE_ONE_OFF").Optional().Nillable(),field.String("cron_expr").MaxLen(64).Optional().Nillable(),field.String("handler").MaxLen(256).Optional().Nillable(),field.JSON("params",&map[string]string{}).Optional(),field.Bool("enable").Default(true).Optional().Nillable()} }
func (Task) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id")} }
