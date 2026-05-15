import { dailyWords, words } from "@/db/schema";
import { and, asc, eq, gt, ilike, ne, notInArray, or, sql } from "drizzle-orm";

export const productIds = {
  weekly: "verbsy.pro.weekly",
  monthly: "verbsy.pro.monthly",
  annual: "verbsy.pro.annual",
} as const;

async function getDb() {
  const { db } = await import("@/db");
  return db;
}

export type WordDTO = {
  id: number;
  slug: string;
  word: string;
  pronunciation: string;
  partOfSpeech: string;
  shortDefinition: string;
  longDefinition: string;
  example: string;
  secondExample: string | null;
  useCase: string;
  difficulty: string;
  topics: string[];
  emotionalTone: string | null;
  isPremium: boolean;
};

export function toWordDTO(row: typeof words.$inferSelect): WordDTO {
  return {
    id: row.id,
    slug: row.slug,
    word: row.word,
    pronunciation: row.pronunciation,
    partOfSpeech: row.partOfSpeech,
    shortDefinition: row.shortDefinition,
    longDefinition: row.longDefinition,
    example: row.example,
    secondExample: row.secondExample,
    useCase: row.useCase,
    difficulty: row.difficulty,
    topics: row.topics,
    emotionalTone: row.emotionalTone,
    isPremium: row.isPremium,
  };
}

export function isoDate(date = new Date()) {
  return date.toISOString().slice(0, 10);
}

export async function getDailyWord(date = isoDate()) {
  const db = await getDb();
  const rows = await db
    .select({ word: words })
    .from(dailyWords)
    .innerJoin(words, eq(words.id, dailyWords.wordId))
    .where(and(eq(dailyWords.date, date), eq(dailyWords.audienceSegment, "all")))
    .limit(1);

  if (rows[0]?.word) return rows[0].word;

  const fallback = await db.select().from(words).orderBy(asc(words.id)).limit(1);
  return fallback[0] ?? null;
}

export async function getTopics() {
  const db = await getDb();
  const rows = await db.select({ topics: words.topics }).from(words);
  return Array.from(new Set(rows.flatMap((row) => row.topics))).sort((a, b) =>
    a.localeCompare(b),
  );
}

export async function getWordBySlug(slug: string) {
  const db = await getDb();
  const rows = await db.select().from(words).where(eq(words.slug, slug)).limit(1);
  return rows[0] ?? null;
}

export async function listWords({
  topic,
  difficulty,
  cursor,
  limit,
  query,
}: {
  topic?: string | null;
  difficulty?: string | null;
  cursor?: number | null;
  limit: number;
  query?: string | null;
}) {
  const db = await getDb();
  const filters = [
    cursor ? gt(words.id, cursor) : undefined,
    difficulty ? eq(words.difficulty, difficulty) : undefined,
    topic ? sql`${topic} = ANY(${words.topics})` : undefined,
    query ? ilike(words.word, `%${query}%`) : undefined,
  ].filter(Boolean);

  const rows = await db
    .select()
    .from(words)
    .where(filters.length ? and(...filters) : undefined)
    .orderBy(asc(words.id))
    .limit(limit + 1);

  const page = rows.slice(0, limit);
  return {
    words: page.map(toWordDTO),
    nextCursor: rows.length > limit ? page.at(-1)?.id ?? null : null,
  };
}

export async function getQuizDistractors(wordId: number, topics: string[]) {
  const db = await getDb();
  const topicFilters = topics.map((topic) => sql<boolean>`${topic} = ANY(${words.topics})`);
  const rows = await db
    .select()
    .from(words)
    .where(and(ne(words.id, wordId), topicFilters.length ? or(...topicFilters) : undefined))
    .orderBy(sql`random()`)
    .limit(3);

  if (rows.length >= 3) return rows;

  const fallback = await db
    .select()
    .from(words)
    .where(and(ne(words.id, wordId), rows.length ? notInArray(words.id, rows.map((row) => row.id)) : undefined))
    .orderBy(sql`random()`)
    .limit(3 - rows.length);

  return [...rows, ...fallback];
}
