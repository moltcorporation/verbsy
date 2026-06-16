import { NextResponse } from "next/server";
import { difficulties, getDailyWord, getTopics, isoDate, productIds, toWordDTO } from "../content";

export const dynamic = "force-dynamic";

export async function GET() {
  const today = isoDate();
  const [dailyWord, topics] = await Promise.all([getDailyWord(today), getTopics()]);

  return NextResponse.json({
    serverDate: today,
    contentVersion: "2026-06-verbsy-2",
    productIds,
    topics,
    difficulties: [...difficulties],
    dailyWord: dailyWord ? toWordDTO(dailyWord) : null,
  });
}
