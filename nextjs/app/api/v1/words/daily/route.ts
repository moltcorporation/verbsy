import { NextResponse } from "next/server";
import { getDailyWord, isoDate, toWordDTO } from "../../content";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  const url = new URL(request.url);
  const date = url.searchParams.get("date") ?? isoDate();
  const word = await getDailyWord(date);

  if (!word) {
    return NextResponse.json({ error: "No daily word is available." }, { status: 404 });
  }

  return NextResponse.json({ date, word: toWordDTO(word) });
}
