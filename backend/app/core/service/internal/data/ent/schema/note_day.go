package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"

	"github.com/tx7do/go-crud/entgo/mixin"
)

type NoteDay struct{ ent.Schema }

func (NoteDay) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entsql.Annotation{Table: "note_days", Charset: "utf8mb4", Collation: "utf8mb4_bin"},
		entsql.WithComments(true),
		schema.Comment("定期提醒表"),
	}
}

func (NoteDay) Mixin() []ent.Mixin { return []ent.Mixin{mixin.AutoIncrementId{}, mixin.TimeAt{}, mixin.OperatorID{}} }

func (NoteDay) Fields() []ent.Field {
	return []ent.Field{
		field.Uint32("user_id").Optional().Nillable(),
		field.String("title").MaxLen(16).NotEmpty().Optional().Nillable(),
		field.String("notes").MaxLen(1024).Optional().Nillable(),
		field.Int64("start_date").Optional().Nillable(),
		field.Int64("end_date").Optional().Nillable(),
		field.Int64("next_date").Optional().Nillable(),
		field.Int32("repeat_type").Default(0).Optional().Nillable(),
		field.Int32("interval").Default(1).Optional().Nillable(),
		field.Int32("total_count").Default(1).Optional().Nillable(),
		field.Int32("run_count").Default(0).Optional().Nillable(),
	}
}

func (NoteDay) Indexes() []ent.Index {
	return []ent.Index{index.Fields("user_id"), index.Fields("next_date"), index.Fields("user_id", "title").Unique().StorageKey("idx_note_day_user_title")}
}
