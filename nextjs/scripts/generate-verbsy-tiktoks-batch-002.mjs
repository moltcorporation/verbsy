import fs from "node:fs";
import path from "node:path";
import sharp from "sharp";

const repoRoot = path.resolve(import.meta.dirname, "../..");
const tiktoksDir = path.join(repoRoot, "tiktoks");
const basePath = path.join(tiktoksDir, "verbsy-9x16-warm-desk-base.png");

const batchDate = "2026-05-15";

const posts = [
  {
    folder: "people-who-drain-your-peace-001",
    hook: ["3 words for people", "who drain your peace"],
    caption:
      "Some behavior gets easier to spot once it has a name. #socialintelligence #wordchoice #verbsy",
    title: "people who drain your peace",
    words: [
      {
        word: "querulous",
        meta: "adj. * KWAIR-yuh-lus",
        definition: "often complaining in a sharp, dissatisfied way.",
        example: "Everything becomes a problem around them.",
      },
      {
        word: "fractious",
        meta: "adj. * FRAK-shus",
        definition: "irritable, difficult, and quick to argue.",
        example: "The mood changes the second they enter.",
      },
      {
        word: "vituperative",
        meta: "adj. * vy-TOO-puh-ruh-tiv",
        definition: "full of bitter, cruel criticism.",
        example: "Not honest. Just verbally punishing.",
      },
    ],
  },
  {
    folder: "feelings-you-hide-too-well-001",
    hook: ["3 words for feelings", "you hide too well"],
    caption:
      "Quiet feelings still deserve precise language. #emotionalvocabulary #selfawareness #verbsy",
    title: "feelings you hide too well",
    words: [
      {
        word: "reticence",
        meta: "noun * RET-ih-sens",
        definition: "the habit of keeping your thoughts or feelings private.",
        example: "Silence, but with a locked door behind it.",
      },
      {
        word: "dysphoria",
        meta: "noun * dis-FOR-ee-uh",
        definition: "a deep unease or dissatisfaction you cannot settle.",
        example: "When nothing fits, including your own mood.",
      },
      {
        word: "melancholia",
        meta: "noun * mel-un-KOH-lee-uh",
        definition: "a heavy, thoughtful sadness that lingers.",
        example: "Sadness with a long shadow.",
      },
    ],
  },
  {
    folder: "stop-saying-very-angry-001",
    hook: ["Stop saying", "\"very angry\""],
    caption:
      "Anger has levels. These words make that obvious. #wordchoice #communication #verbsy",
    title: "stop saying very angry",
    words: [
      {
        word: "irate",
        meta: "adj. * eye-RAYT",
        definition: "openly and intensely angry.",
        example: "Too angry to sound casual anymore.",
      },
      {
        word: "choleric",
        meta: "adj. * KOL-er-ik",
        definition: "quick-tempered and easily provoked.",
        example: "A short fuse disguised as a personality.",
      },
      {
        word: "apoplectic",
        meta: "adj. * ap-uh-PLEK-tik",
        definition: "furious to the point of losing control.",
        example: "When anger takes over the whole face.",
      },
    ],
  },
  {
    folder: "dangerously-articulate-words-001",
    hook: ["3 words that sound", "dangerously articulate"],
    caption:
      "Use these when your point needs to land cleanly. #articulate #wordchoice #verbsy",
    title: "dangerously articulate words",
    words: [
      {
        word: "trenchant",
        meta: "adj. * TREN-chunt",
        definition: "sharp, forceful, and clearly expressed.",
        example: "A trenchant comment makes the room pause.",
      },
      {
        word: "lucid",
        meta: "adj. * LOO-sid",
        definition: "clear, easy to understand, and mentally sharp.",
        example: "The best ideas feel lucid, not loud.",
      },
      {
        word: "deft",
        meta: "adj. * DEFT",
        definition: "skillful, quick, and graceful.",
        example: "A deft reply fixes the tension without force.",
      },
    ],
  },
  {
    folder: "quiet-confidence-words-001",
    hook: ["3 words for", "quiet confidence"],
    caption:
      "Confidence is better when it does not need to announce itself. #mindsetwords #communication #verbsy",
    title: "quiet confidence words",
    words: [
      {
        word: "sangfroid",
        meta: "noun * sahn-FRWAH",
        definition: "calm self-control under pressure.",
        example: "The kind of calm that unsettles chaos.",
      },
      {
        word: "aplomb",
        meta: "noun * uh-PLOM",
        definition: "composed confidence in a difficult moment.",
        example: "Grace, but under real pressure.",
      },
      {
        word: "equanimity",
        meta: "noun * ee-kwuh-NIM-ih-tee",
        definition: "mental calm, even when things get difficult.",
        example: "Peace that does not collapse on contact.",
      },
    ],
  },
];

function escapeXml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function wrap(text, max) {
  const words = text.split(" ");
  const lines = [];
  let line = "";
  for (const word of words) {
    const next = line ? `${line} ${word}` : word;
    if (next.length > max && line) {
      lines.push(line);
      line = word;
    } else {
      line = next;
    }
  }
  if (line) lines.push(line);
  return lines;
}

function tspans(lines, { x, size, lineHeight = 1.12 }) {
  return lines
    .map((line, index) => {
      const dy = index === 0 ? 0 : size * lineHeight;
      return `<tspan x="${x}" dy="${index === 0 ? 0 : dy}">${escapeXml(line)}</tspan>`;
    })
    .join("");
}

async function renderSlide({ outputPath, kind, hook, item, index, total }) {
  const overlay =
    kind === "hook"
      ? `
      <svg width="1080" height="1920" viewBox="0 0 1080 1920" xmlns="http://www.w3.org/2000/svg">
        <rect x="0" y="0" width="1080" height="1920" fill="rgba(7,10,10,0.10)"/>
        <rect x="76" y="502" width="928" height="726" rx="28" fill="rgba(246,241,226,0.89)"/>
        <rect x="76" y="502" width="8" height="726" fill="#2f735d"/>
        <text x="136" y="658" fill="#0d100e" font-family="Georgia, Times New Roman, serif" font-size="64" font-weight="750" letter-spacing="0">${tspans(hook, { x: 136, size: 64 })}</text>
        <text x="138" y="1050" fill="#3f5148" font-family="Arial, Helvetica, sans-serif" font-size="29" font-weight="800" letter-spacing="3">SAVE THIS WORD SET</text>
        <circle cx="140" cy="1152" r="5" fill="#2f735d"/><circle cx="168" cy="1152" r="5" fill="#2f735d"/><circle cx="196" cy="1152" r="5" fill="#2f735d"/>
      </svg>`
      : `
      <svg width="1080" height="1920" viewBox="0 0 1080 1920" xmlns="http://www.w3.org/2000/svg">
        <rect x="0" y="0" width="1080" height="1920" fill="rgba(7,10,10,0.12)"/>
        <rect x="76" y="400" width="928" height="928" rx="28" fill="rgba(246,241,226,0.90)"/>
        <rect x="76" y="400" width="8" height="928" fill="#2f735d"/>
        <text x="136" y="508" fill="#52665c" font-family="Arial, Helvetica, sans-serif" font-size="27" font-weight="800" letter-spacing="3">${String(index).padStart(2, "0")} / ${String(total).padStart(2, "0")}</text>
        <text x="136" y="680" fill="#0c0f0d" font-family="Georgia, Times New Roman, serif" font-size="100" font-weight="750" letter-spacing="0">${escapeXml(item.word)}</text>
        <text x="140" y="752" fill="#35423b" font-family="Arial, Helvetica, sans-serif" font-size="33" font-weight="700" letter-spacing="0">${escapeXml(item.meta)}</text>
        <line x1="136" y1="814" x2="408" y2="814" stroke="#2f735d" stroke-width="4"/>
        <text x="136" y="924" fill="#0d100e" font-family="Georgia, Times New Roman, serif" font-size="52" font-weight="650" letter-spacing="0">${tspans(wrap(item.definition, 30), { x: 136, size: 52, lineHeight: 1.18 })}</text>
        <text x="140" y="1186" fill="#2f3833" font-family="Arial, Helvetica, sans-serif" font-size="35" font-weight="650" letter-spacing="0">${tspans(wrap(item.example, 39), { x: 140, size: 35, lineHeight: 1.24 })}</text>
      </svg>`;

  await sharp(basePath)
    .resize(1080, 1920, { fit: "cover" })
    .composite([{ input: Buffer.from(overlay), top: 0, left: 0 }])
    .png({ quality: 95 })
    .toFile(outputPath);
}

async function main() {
  if (!fs.existsSync(basePath)) {
    throw new Error(`Missing base image: ${basePath}`);
  }

  for (const post of posts) {
    const dir = path.join(tiktoksDir, post.folder);
    fs.mkdirSync(dir, { recursive: true });
    await renderSlide({
      outputPath: path.join(dir, "slide1.png"),
      kind: "hook",
      hook: post.hook,
    });
    for (const [i, item] of post.words.entries()) {
      await renderSlide({
        outputPath: path.join(dir, `slide${i + 2}.png`),
        kind: "word",
        item,
        index: i + 1,
        total: post.words.length,
      });
    }
    fs.writeFileSync(path.join(dir, "caption.txt"), `${post.caption}\n`);
  }

  const usedPath = path.join(tiktoksDir, "used-words.txt");
  const used = new Set(
    fs
      .readFileSync(usedPath, "utf8")
      .split(/\r?\n/)
      .map((line) => line.trim().toLowerCase())
      .filter(Boolean),
  );
  for (const post of posts) {
    for (const item of post.words) used.add(item.word.toLowerCase());
  }
  fs.writeFileSync(usedPath, `${[...used].sort().join("\n")}\n`);

  const conceptPath = path.join(tiktoksDir, "used-post-concepts.txt");
  const existingConcepts = fs.existsSync(conceptPath)
    ? fs
        .readFileSync(conceptPath, "utf8")
        .split(/\r?\n/)
        .map((line) => line.trim())
        .filter(Boolean)
    : [];
  const conceptLines = posts.map((post) => {
    const hook = post.hook.join(" ");
    const words = post.words.map((item) => item.word.toLowerCase()).join(", ");
    return `${batchDate} | ${post.folder} | ${hook} | ${words}`;
  });
  fs.writeFileSync(
    conceptPath,
    `${[...new Set([...existingConcepts, ...conceptLines])].join("\n")}\n`,
  );

  fs.writeFileSync(
    path.join(tiktoksDir, "verbsy-batch-2026-05-15-vocabmaxx.json"),
    `${JSON.stringify(posts, null, 2)}\n`,
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
