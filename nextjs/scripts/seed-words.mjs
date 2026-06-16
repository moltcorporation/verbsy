import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { neon } from "@neondatabase/serverless";

// Canonical word corpus. This same file is bundled into the iOS app
// (ios/verbsy/words.json) so the Learn feed works offline / on first launch.
const here = dirname(fileURLToPath(import.meta.url));
const words = JSON.parse(await readFile(join(here, "words.json"), "utf8"));

if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL is required to seed Verbsy words.");
}

const sql = neon(process.env.DATABASE_URL);

for (const item of words) {
  await sql`
    insert into words (
      slug, word, pronunciation, part_of_speech,
      short_definition, long_definition, example, second_example,
      use_case, origin, synonyms, difficulty, topics, emotional_tone, is_premium
    )
    values (
      ${item.slug}, ${item.word}, ${item.pronunciation}, ${item.partOfSpeech},
      ${item.shortDefinition}, ${item.longDefinition}, ${item.example}, ${item.secondExample ?? null},
      ${item.useCase}, ${item.origin ?? null}, ${item.synonyms ?? []}, ${item.difficulty}, ${item.topics}, ${item.emotionalTone ?? null}, true
    )
    on conflict (slug) do update set
      word = excluded.word,
      pronunciation = excluded.pronunciation,
      part_of_speech = excluded.part_of_speech,
      short_definition = excluded.short_definition,
      long_definition = excluded.long_definition,
      example = excluded.example,
      second_example = excluded.second_example,
      use_case = excluded.use_case,
      origin = excluded.origin,
      synonyms = excluded.synonyms,
      difficulty = excluded.difficulty,
      topics = excluded.topics,
      emotional_tone = excluded.emotional_tone,
      updated_at = now()
  `;
}

// Remove any words no longer in the canonical corpus (their daily_words rows
// cascade-delete) so the database matches words.json exactly.
const slugs = words.map((item) => item.slug);
await sql`delete from words where slug <> all(${slugs})`;

// Resolve every slug to its database id, then schedule a daily word for the
// next ~12 months so the daily endpoint, widget, and notification always
// resolve (round-robin through the corpus).
const idBySlug = new Map();
for (const item of words) {
  const rows = await sql`select id from words where slug = ${item.slug} limit 1`;
  if (rows[0]?.id) idBySlug.set(item.slug, rows[0].id);
}
const wordIds = words.map((item) => idBySlug.get(item.slug)).filter(Boolean);

const today = new Date();
const dateForOffset = (offset) => {
  const date = new Date(today);
  date.setUTCDate(date.getUTCDate() + offset);
  return date.toISOString().slice(0, 10);
};

const DAYS = 366;
let scheduled = 0;
for (let offset = 0; offset < DAYS; offset += 1) {
  const wordId = wordIds[offset % wordIds.length];
  if (!wordId) continue;
  await sql`
    insert into daily_words (date, word_id, audience_segment)
    values (${dateForOffset(offset)}, ${wordId}, 'all')
    on conflict (date, audience_segment) do update set word_id = excluded.word_id
  `;
  scheduled += 1;
}

console.log(`Seeded ${words.length} Verbsy words and ${scheduled} daily schedule rows.`);
