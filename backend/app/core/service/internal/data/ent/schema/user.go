package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"
	"github.com/tx7do/go-crud/entgo/mixin"
)

type User struct{ ent.Schema }

func (User) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "sys_users", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("用户表"),
	}
}

func (User) Mixin() []ent.Mixin {
	return []ent.Mixin{
		mixin.AutoIncrementId{},
		mixin.OperatorID{},
		mixin.TimeAt{},
		mixin.Remark{},
		mixin.TenantID[uint32]{},
	}
}

func (User) Fields() []ent.Field {
	return []ent.Field{
		field.String("username").Comment("用户名").MaxLen(16).Optional().Nillable(),
		field.String("nickname").Comment("昵称").MaxLen(16).Optional().Nillable(),
		field.String("realname").Comment("真实姓名").MaxLen(32).Optional().Nillable(),
		field.String("password").Comment("密码").MaxLen(64).Optional().Nillable().Sensitive(),
		field.String("avatar").Comment("头像").MaxLen(256).Optional().Nillable(),
		field.String("email").Comment("邮箱").MaxLen(32).Optional().Nillable(),
		field.String("mobile").Comment("手机号").MaxLen(16).Optional().Nillable(),
		field.String("telephone").Comment("电话").MaxLen(16).Optional().Nillable(),
		field.Enum("gender").Comment("性别").NamedValues("GenderSecret","GENDER_SECRET","GenderMale","GENDER_MALE","GenderFemale","GENDER_FEMALE").Optional().Nillable(),
		field.String("address").Comment("地址").MaxLen(256).Optional().Nillable(),
		field.String("region").Comment("地区").MaxLen(64).Optional().Nillable(),
		field.String("description").Comment("描述").MaxLen(128).Optional().Nillable(),
		field.Enum("status").Comment("用户状态").NamedValues("UserStatusNormal","NORMAL","UserStatusDisabled","DISABLED","UserStatusPending","PENDING","UserStatusLocked","LOCKED","UserStatusExpired","EXPIRED","UserStatusClosed","CLOSED").Default("NORMAL").Optional().Nillable(),
		field.Time("last_login_at").Comment("最后登录时间").Optional().Nillable(),
		field.String("last_login_ip").Comment("最后登录IP").MaxLen(45).Optional().Nillable(),
		field.Time("locked_until").Comment("锁定截止时间").Optional().Nillable(),
		field.Uint64("followers").Comment("粉丝数").Default(0).Optional().Nillable(),
		field.Uint64("following").Comment("关注数").Default(0).Optional().Nillable(),
		field.Uint64("post_count").Comment("文章数").Default(0).Optional().Nillable(),
		field.Uint64("comment_count").Comment("评论数").Default(0).Optional().Nillable(),
		field.Uint64("like_count").Comment("获赞数").Default(0).Optional().Nillable(),
		field.Uint32("default_group_id").Comment("默认群组(租户)ID").Optional().Nillable(),
		field.Uint32("default_book_id").Comment("默认账本ID").Optional().Nillable(),
	}
}

func (User) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("tenant_id", "username").Unique().StorageKey("idx_user_tenant_username"),
		index.Fields("tenant_id"),
		index.Fields("status"),
		index.Fields("email"),
		index.Fields("mobile"),
	}
}
