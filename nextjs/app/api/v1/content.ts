import { dailyWords, words } from "@/db/schema";
import { and, asc, eq, gt, ilike, inArray, ne, notInArray, or, sql } from "drizzle-orm";

export const productIds = {
  monthly: "verbsy.pro.monthly",
  annual: "verbsy.pro.annual",
} as const;

export const difficulties = ["casual", "curious", "advanced"] as const;

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
  origin: string | null;
  synonyms: string[];
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
    origin: row.origin ?? null,
    synonyms: row.synonyms ?? [],
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

// Build OR-across-topics / IN-across-difficulties filters shared by list + feed + quiz.
function preferenceFilters(topics?: string[] | null, difficulties?: string[] | null) {
  const topicFilters = (topics ?? []).filter(Boolean).map(
    (topic) => sql<boolean>`${topic} = ANY(${words.topics})`,
  );
  const list = (difficulties ?? []).filter(Boolean);
  return [
    topicFilters.length ? or(...topicFilters) : undefined,
    list.length ? inArray(words.difficulty, list) : undefined,
  ].filter(Boolean);
}

export async function listWords({
  topic,
  topics,
  difficulty,
  difficulties,
  cursor,
  limit,
  query,
}: {
  topic?: string | null;
  topics?: string[] | null;
  difficulty?: string | null;
  difficulties?: string[] | null;
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
    ...preferenceFilters(topics, difficulties),
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

// Deterministically shuffled, offset-paginated feed. Stable within a session
// (same seed) yet varied across sessions. Powers the infinite Learn feed.
export async function getFeed({
  topics,
  difficulties,
  seed,
  offset,
  limit,
}: {
  topics?: string[] | null;
  difficulties?: string[] | null;
  seed: string;
  offset: number;
  limit: number;
}) {
  const db = await getDb();
  const filters = preferenceFilters(topics, difficulties);

  const rows = await db
    .select()
    .from(words)
    .where(filters.length ? and(...filters) : undefined)
    .orderBy(sql`md5(${words.slug} || ${seed})`)
    .offset(offset)
    .limit(limit + 1);

  const page = rows.slice(0, limit);
  return {
    words: page.map(toWordDTO),
    nextOffset: rows.length > limit ? offset + limit : null,
  };
}

// A batch of quiz questions for the infinite Quiz feed: each word plus three
// distractors, shuffled by display word.
export async function getQuizBatch(params: {
  topics?: string[] | null;
  difficulties?: string[] | null;
  seed: string;
  offset: number;
  limit: number;
}) {
  const feed = await getFeed(params);
  const items = await Promise.all(
    feed.words.map(async (word) => {
      const distractors = await getQuizDistractors(word.id, word.topics);
      const options = [word, ...distractors.map(toWordDTO)]
        .sort((a, b) => a.word.localeCompare(b.word));
      return {
        prompt: `What does "${word.word}" mean?`,
        correctSlug: word.slug,
        word,
        options,
      };
    }),
  );
  return { items, nextOffset: feed.nextOffset };
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
