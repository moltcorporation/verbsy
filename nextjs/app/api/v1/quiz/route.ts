import { NextResponse } from "next/server";
import { getQuizBatch } from "../content";

export const dynamic = "force-dynamic";

function csv(value: string | null) {
  if (!value) return null;
  return value
    .split(",")
    .map((part) => part.trim())
    .filter(Boolean);
}

export async function GET(request: Request) {
  const url = new URL(request.url);
  const limit = Math.min(Math.max(Number(url.searchParams.get("limit") ?? 10), 1), 20);
  const offset = Math.max(Number(url.searchParams.get("offset") ?? 0), 0);
  const seed = url.searchParams.get("seed") || "verbsy";

  const result = await getQuizBatch({
    topics: csv(url.searchParams.get("topics")),
    difficulties: csv(url.searchParams.get("difficulties")),
    seed,
    offset: Number.isFinite(offset) ? offset : 0,
    limit,
  });

  return NextResponse.json(result);
}
