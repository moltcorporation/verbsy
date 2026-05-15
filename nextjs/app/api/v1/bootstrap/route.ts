import { NextResponse } from "next/server";
import { getDailyWord, getTopics, isoDate, productIds, toWordDTO } from "../content";

export const dynamic = "force-dynamic";

export async function GET() {
  const today = isoDate();
  const [dailyWord, topics] = await Promise.all([getDailyWord(today), getTopics()]);

  return NextResponse.json({
    serverDate: today,
    contentVersion: "2026-05-verbsy-mvp-1",
    productIds,
    topics,
    dailyWord: dailyWord ? toWordDTO(dailyWord) : null,
  });
}
