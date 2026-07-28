package schema
import ("entgo.io/ent";"entgo.io/ent/dialect/entsql";"entgo.io/ent/schema";"entgo.io/ent/schema/field";"entgo.io/ent/schema/index";"github.com/tx7do/go-crud/entgo/mixin")
type File struct{ ent.Schema }
func (File) Annotations() []schema.Annotation { return []schema.Annotation{entsql.Annotation{Table:"files",Charset:"utf8mb4",Collation:"utf8mb4_bin"},entsql.WithComments(true),schema.Comment("文件表")} }
func (File) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{},mixin.TimeAt{},mixin.OperatorID{},mixin.TenantID[uint32]{}} }
func (File) Fields() []ent.Field {
	return []ent.Field{
		field.String("name").Comment("文件名").MaxLen(256).Optional().Nillable(),
		field.String("original_name").Comment("原始文件名").MaxLen(512).Optional().Nillable(),
		field.String("content_type").Comment("MIME类型").MaxLen(64).Optional().Nillable(),
		field.Int64("size").Comment("文件大小").Optional().Nillable(),
		field.String("path").Comment("存储路径").MaxLen(512).Optional().Nillable(),
		field.String("url").Comment("访问URL").MaxLen(1024).Optional().Nillable(),
		field.Enum("provider").NamedValues("ProviderLocal","PROVIDER_LOCAL","ProviderMinio","PROVIDER_MINIO","ProviderOss","PROVIDER_OSS").Default("PROVIDER_LOCAL").Optional().Nillable(),
		field.String("object_key").Comment("对象Key").MaxLen(256).Optional().Nillable(),
	}
}
func (File) Indexes() []ent.Index { return []ent.Index{index.Fields("tenant_id"),index.Fields("object_key")} }
