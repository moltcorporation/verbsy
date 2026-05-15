import { NextResponse } from "next/server";
import { listWords } from "../content";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  const url = new URL(request.url);
  const limit = Math.min(Math.max(Number(url.searchParams.get("limit") ?? 24), 1), 50);
  const cursorParam = url.searchParams.get("cursor");
  const cursor = cursorParam ? Number(cursorParam) : null;

  const result = await listWords({
    topic: url.searchParams.get("topic"),
    difficulty: url.searchParams.get("difficulty"),
    query: url.searchParams.get("q"),
    cursor: Number.isFinite(cursor) ? cursor : null,
    limit,
  });

  return NextResponse.json(result);
}
