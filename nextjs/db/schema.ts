import {
  boolean,
  date,
  integer,
  pgTable,
  serial,
  text,
  timestamp,
  uniqueIndex,
} from "drizzle-orm/pg-core";

export const words = pgTable(
  "words",
  {
    id: serial("id").primaryKey(),
    slug: text("slug").notNull().unique(),
    word: text("word").notNull(),
    pronunciation: text("pronunciation").notNull(),
    partOfSpeech: text("part_of_speech").notNull(),
    shortDefinition: text("short_definition").notNull(),
    longDefinition: text("long_definition").notNull(),
    example: text("example").notNull(),
    secondExample: text("second_example"),
    useCase: text("use_case").notNull(),
    difficulty: text("difficulty").notNull(),
    topics: text("topics").array().notNull(),
    emotionalTone: text("emotional_tone"),
    isPremium: boolean("is_premium").notNull().default(true),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at").defaultNow().notNull(),
  },
  (table) => [uniqueIndex("words_slug_idx").on(table.slug)],
);

export const dailyWords = pgTable(
  "daily_words",
  {
    id: serial("id").primaryKey(),
    date: date("date").notNull(),
    wordId: integer("word_id")
      .notNull()
      .references(() => words.id, { onDelete: "cascade" }),
    audienceSegment: text("audience_segment").notNull().default("all"),
    createdAt: timestamp("created_at").defaultNow().notNull(),
  },
  (table) => [uniqueIndex("daily_words_date_segment_idx").on(table.date, table.audienceSegment)],
);
