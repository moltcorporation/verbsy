import { NextResponse } from "next/server";
import { getQuizDistractors, getWordBySlug, toWordDTO } from "../../content";

export const dynamic = "force-dynamic";

export async function GET(
  _request: Request,
  context: { params: Promise<{ slug: string }> },
) {
  const { slug } = await context.params;
  const word = await getWordBySlug(slug);

  if (!word) {
    return NextResponse.json({ error: "Word not found." }, { status: 404 });
  }

  const distractors = await getQuizDistractors(word.id, word.topics);

  return NextResponse.json({
    word: toWordDTO(word),
    quiz: {
      prompt: `What does "${word.word}" mean?`,
      correctSlug: word.slug,
      options: [word, ...distractors]
        .map(toWordDTO)
        .sort((a, b) => a.word.localeCompare(b.word)),
    },
  });
}
