#!/usr/bin/env node
import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "../../nextjs/node_modules/sharp/lib/index.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, "../..");
const rawDir = path.join(repoRoot, "ios/screenshots/en-US");
const outDir = path.join(repoRoot, "ios/screenshots/appstore-en-US");
const iconPath = path.join(repoRoot, "ios/verbsy/Assets.xcassets/AppIcon.appiconset/verbsy-app-icon.png");

const W = 1320;
const H = 2868;
const colors = {
  paper: "#FAF8F2",
  surface: "#FFFFFF",
  panel: "#F3F1E9",
  ink: "#1A1916",
  muted: "#6B6A63",
  line: "#E7E4D9",
  sage: "#356B52",
  sageSoft: "#E4EBE0",
  gold: "#BE8A3D",
  goldSoft: "#F3E9D4",
};

const gallery = [
  {
    file: "01_daily_word.png",
    source: "01_learn.png",
    title: "Learn one new word every day",
    subtitle: "Definitions, examples, origins, and pronunciation in one simple feed.",
  },
  {
    file: "04_topics.png",
    source: "04_topics.png",
    title: "Choose topics you care about",
    subtitle: "Personalize your daily words around interests like ideas, writing, and work.",
  },
  {
    file: "05_difficulty.png",
    source: "05_difficulty.png",
    title: "Set your word difficulty",
    subtitle: "Keep words everyday, curious, advanced, or mix all three.",
  },
  {
    file: "06_quiz.png",
    source: "06_quiz.png",
    title: "Practice with quick quizzes",
    subtitle: "Swipe through simple questions that help new words stick.",
  },
  {
    file: "07_progress.png",
    source: "07_home.png",
    title: "Save favorites and track progress",
    subtitle: "Build a streak, review saved words, and keep learning lightweight.",
  },
  {
    file: "08_pro.png",
    source: "08_paywall.png",
    title: "Unlock widgets and reminders",
    subtitle: "Verbsy Pro adds daily word notifications and widget customization.",
  },
];

function escapeXml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function textLines(text, maxChars) {
  const words = text.split(/\s+/);
  const lines = [];
  let current = "";
  for (const word of words) {
    const next = current ? `${current} ${word}` : word;
    if (next.length > maxChars && current) {
      lines.push(current);
      current = word;
    } else {
      current = next;
    }
  }
  if (current) lines.push(current);
  return lines;
}

function captionSvg(title, subtitle) {
  const titleLines = textLines(title, 25);
  const subtitleLines = textLines(subtitle, 44);
  const titleTspans = titleLines.map((line, i) =>
    `<tspan x="96" dy="${i === 0 ? 0 : 76}">${escapeXml(line)}</tspan>`
  ).join("");
  const subtitleTspans = subtitleLines.map((line, i) =>
    `<tspan x="96" dy="${i === 0 ? 0 : 42}">${escapeXml(line)}</tspan>`
  ).join("");
  const subtitleY = 150 + (titleLines.length - 1) * 76 + 62;
  return Buffer.from(`
    <svg width="${W}" height="430" viewBox="0 0 ${W} 430" xmlns="http://www.w3.org/2000/svg">
      <text x="96" y="150" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display', serif"
        font-size="64" font-weight="750" fill="${colors.ink}" letter-spacing="0">${titleTspans}</text>
      <text x="96" y="${subtitleY}" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif"
        font-size="31" font-weight="560" fill="${colors.muted}" letter-spacing="0">${subtitleTspans}</text>
    </svg>
  `);
}

function phoneMaskSvg(width, height, radius) {
  return Buffer.from(`
    <svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
      <rect x="0" y="0" width="${width}" height="${height}" rx="${radius}" ry="${radius}" fill="#fff"/>
    </svg>
  `);
}

function phoneFrameSvg(x, y, width, height, radius) {
  return Buffer.from(`
    <svg width="${W}" height="${H}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <filter id="shadow" x="-40%" y="-20%" width="180%" height="150%">
          <feDropShadow dx="0" dy="34" stdDeviation="34" flood-color="#1A1916" flood-opacity="0.22"/>
        </filter>
      </defs>
      <rect x="${x - 16}" y="${y - 16}" width="${width + 32}" height="${height + 32}" rx="${radius + 22}"
        fill="#111111" filter="url(#shadow)"/>
      <rect x="${x}" y="${y}" width="${width}" height="${height}" rx="${radius}"
        fill="${colors.paper}"/>
    </svg>
  `);
}

async function framedScreenshot({ source, title, subtitle, file }) {
  const phoneW = 1040;
  const phoneH = Math.round(phoneW * H / W);
  const phoneX = Math.round((W - phoneW) / 2);
  const phoneY = 520;
  const radius = 82;
  const sourcePath = path.join(rawDir, source);
  const shot = await sharp(sourcePath)
    .resize(phoneW, phoneH)
    .composite([{ input: phoneMaskSvg(phoneW, phoneH, radius), blend: "dest-in" }])
    .png()
    .toBuffer();

  await sharp({
    create: { width: W, height: H, channels: 3, background: colors.paper },
  })
    .composite([
      { input: captionSvg(title, subtitle), left: 0, top: 0 },
      { input: phoneFrameSvg(phoneX, phoneY, phoneW, phoneH, radius), left: 0, top: 0 },
      { input: shot, left: phoneX, top: phoneY },
    ])
    .flatten({ background: colors.paper })
    .removeAlpha()
    .png({ compressionLevel: 9 })
    .toFile(path.join(outDir, file));
}

function lockScreenSvg({ kind }) {
  const isNotification = kind === "notification";
  const title = isNotification ? "Daily reminders" : "Home and Lock Screen widgets";
  const subtitle = isNotification
    ? "Get a new word at the frequency you choose."
    : "Keep your daily word visible without opening the app.";
  const body = isNotification
    ? `
      <rect x="110" y="460" width="900" height="170" rx="42" fill="rgba(255,255,255,0.72)" stroke="rgba(255,255,255,0.55)"/>
      <image href="data:image/png;base64,${iconBase64}" x="150" y="500" width="82" height="82"/>
      <text x="252" y="522" font-size="25" font-weight="750" fill="${colors.ink}">Verbsy</text>
      <text x="252" y="565" font-size="33" font-weight="760" fill="${colors.ink}">Lucid</text>
      <text x="252" y="606" font-size="25" font-weight="560" fill="${colors.muted}">Clear, bright, and easy to understand.</text>
      <text x="874" y="522" font-size="23" font-weight="560" fill="${colors.muted}">now</text>
      <g transform="translate(168 760)">
        <rect x="0" y="0" width="784" height="142" rx="30" fill="${colors.surface}" stroke="${colors.line}"/>
        <text x="42" y="55" font-size="29" font-weight="760" fill="${colors.ink}">Words per day</text>
        <text x="682" y="55" font-size="30" font-weight="800" fill="${colors.sage}">3</text>
        <line x1="42" y1="80" x2="742" y2="80" stroke="${colors.line}" />
        <text x="42" y="118" font-size="28" font-weight="760" fill="${colors.ink}">First reminder</text>
        <text x="602" y="118" font-size="28" font-weight="800" fill="${colors.sage}">9:00 AM</text>
      </g>`
    : `
      <g transform="translate(120 410)">
        <rect x="0" y="0" width="880" height="360" rx="52" fill="${colors.surface}" stroke="${colors.line}"/>
        <text x="54" y="82" font-size="24" font-weight="850" fill="${colors.sage}" letter-spacing="5">VERBSY</text>
        <text x="54" y="174" font-size="76" font-weight="850" fill="${colors.ink}" font-family="Georgia, serif">Lucid</text>
        <text x="56" y="228" font-size="29" font-weight="720" fill="${colors.sage}">LOO-sid · adjective</text>
        <text x="56" y="286" font-size="30" font-weight="620" fill="${colors.muted}">Clear, bright, and easy to understand.</text>
      </g>
      <g transform="translate(170 860)">
        <rect x="0" y="0" width="270" height="270" rx="54" fill="${colors.ink}"/>
        <text x="34" y="78" font-size="20" font-weight="850" fill="${colors.gold}" letter-spacing="4">VERBSY</text>
        <text x="36" y="168" font-size="54" font-weight="850" fill="${colors.paper}" font-family="Georgia, serif">Poise</text>
        <text x="38" y="214" font-size="22" font-weight="650" fill="#D9A85A">noun</text>
      </g>
      <g transform="translate(500 870)">
        <rect x="0" y="0" width="430" height="116" rx="28" fill="rgba(255,255,255,0.72)" stroke="rgba(255,255,255,0.55)"/>
        <text x="30" y="47" font-size="30" font-weight="850" fill="${colors.ink}" font-family="Georgia, serif">Acuity</text>
        <text x="30" y="82" font-size="22" font-weight="640" fill="${colors.muted}">Sharpness of thought</text>
      </g>`;

  return Buffer.from(`
    <svg width="1120" height="2100" viewBox="0 0 1120 2100" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="wall" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="${colors.sageSoft}"/>
          <stop offset="54%" stop-color="${colors.paper}"/>
          <stop offset="100%" stop-color="${colors.goldSoft}"/>
        </linearGradient>
        <filter id="soft"><feDropShadow dx="0" dy="24" stdDeviation="28" flood-color="#1A1916" flood-opacity="0.18"/></filter>
      </defs>
      <rect width="1120" height="2100" rx="96" fill="url(#wall)"/>
      <text x="560" y="145" text-anchor="middle" font-size="38" font-weight="720" fill="${colors.ink}">9:00</text>
      <text x="560" y="240" text-anchor="middle" font-size="102" font-weight="760" fill="${colors.ink}">Verbsy</text>
      <text x="560" y="302" text-anchor="middle" font-size="34" font-weight="560" fill="${colors.muted}">${subtitle}</text>
      <g filter="url(#soft)">${body}</g>
      <rect x="350" y="1960" width="420" height="10" rx="5" fill="rgba(26,25,22,0.45)"/>
    </svg>
  `);
}

let iconBase64 = "";

async function previewScreenshot({ kind, file, title, subtitle }) {
  const phoneW = 1000;
  const phoneH = 1875;
  const phoneX = Math.round((W - phoneW) / 2);
  const phoneY = 700;
  const radius = 90;
  const preview = await sharp(lockScreenSvg({ kind }))
    .resize(phoneW, phoneH)
    .composite([{ input: phoneMaskSvg(phoneW, phoneH, radius), blend: "dest-in" }])
    .png()
    .toBuffer();

  await sharp({
    create: { width: W, height: H, channels: 3, background: colors.paper },
  })
    .composite([
      { input: captionSvg(title, subtitle), left: 0, top: 0 },
      { input: phoneFrameSvg(phoneX, phoneY, phoneW, phoneH, radius), left: 0, top: 0 },
      { input: preview, left: phoneX, top: phoneY },
    ])
    .flatten({ background: colors.paper })
    .removeAlpha()
    .png({ compressionLevel: 9 })
    .toFile(path.join(outDir, file));
}

async function main() {
  await fs.rm(outDir, { recursive: true, force: true });
  await fs.mkdir(outDir, { recursive: true });
  iconBase64 = (await sharp(iconPath).resize(96, 96).png().toBuffer()).toString("base64");

  await framedScreenshot(gallery[0]);
  await previewScreenshot({
    kind: "widgets",
    file: "02_widgets.png",
    title: "Add words to your Home and Lock Screen",
    subtitle: "Widgets keep vocabulary visible throughout the day.",
  });
  await previewScreenshot({
    kind: "notification",
    file: "03_reminders.png",
    title: "Get daily word reminders",
    subtitle: "Choose your word topics, difficulty, and reminder frequency.",
  });
  for (const item of gallery.slice(1)) {
    await framedScreenshot(item);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
