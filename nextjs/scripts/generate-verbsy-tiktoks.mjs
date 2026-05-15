import fs from "node:fs";
import path from "node:path";
import sharp from "sharp";

const repoRoot = path.resolve(import.meta.dirname, "../..");
const tiktoksDir = path.join(repoRoot, "tiktoks");
const basePath = path.join(tiktoksDir, "verbsy-9x16-editorial-base.png");

const posts = [
  {
    folder: "quietly-brilliant-words-001",
    hook: ["5 words that make you", "sound quietly brilliant"],
    caption:
      "Tiny vocabulary upgrade, massive difference. #wordchoice #communication #vocabulary #verbsy",
    title: "quietly brilliant words",
    words: [
      {
        word: "cogent",
        meta: "adj. * KOH-jent",
        definition: "clear, logical, and convincing.",
        example: "A cogent point is hard to dismiss.",
      },
      {
        word: "incisive",
        meta: "adj. * in-SY-siv",
        definition: "sharply clear and perceptive.",
        example: "An incisive question cuts through noise.",
      },
      {
        word: "judicious",
        meta: "adj. * joo-DISH-us",
        definition: "showing careful, wise judgment.",
        example: "A judicious reply says enough, not too much.",
      },
      {
        word: "erudite",
        meta: "adj. * AIR-yoo-dyte",
        definition: "having deep, refined knowledge.",
        example: "Erudite does not have to mean pretentious.",
      },
      {
        word: "nuanced",
        meta: "adj. * NOO-ahnst",
        definition: "showing subtle differences in meaning.",
        example: "A nuanced take makes people listen longer.",
      },
    ],
  },
  {
    folder: "sadness-that-hits-different-001",
    hook: ["3 words for sadness", "that hits differently"],
    caption:
      "Some sadness is too specific for one basic word. #emotionalintelligence #wordchoice #verbsy",
    title: "sadness words",
    words: [
      {
        word: "hiraeth",
        meta: "noun * HEER-eyeth",
        definition: "a deep longing for a home you cannot return to.",
        example: "It is nostalgia with a bruise under it.",
      },
      {
        word: "saudade",
        meta: "noun * sow-DAH-duh",
        definition: "a tender ache for someone or something absent.",
        example: "Missing them, but almost loving the missing.",
      },
      {
        word: "weltschmerz",
        meta: "noun * VELT-shmairts",
        definition: "sadness from seeing how flawed the world is.",
        example: "Idealism after it meets reality.",
      },
    ],
  },
  {
    folder: "read-people-too-well-001",
    hook: ["3 words that help you", "read people too well"],
    caption:
      "Once you can name the pattern, it gets harder to ignore. #psychologywords #communication #verbsy",
    title: "read people better",
    words: [
      {
        word: "obsequious",
        meta: "adj. * ub-SEE-kwee-us",
        definition: "too eager to please someone powerful.",
        example: "Polite on the surface, strategic underneath.",
      },
      {
        word: "recalcitrant",
        meta: "adj. * ri-KAL-si-trunt",
        definition: "stubbornly resistant to authority or advice.",
        example: "Not independent. Just impossible to steer.",
      },
      {
        word: "solipsistic",
        meta: "adj. * sol-ip-SIS-tik",
        definition: "acting as if only your own mind matters.",
        example: "Every story somehow becomes about them.",
      },
    ],
  },
  {
    folder: "feelings-you-couldnt-name-002",
    hook: ["5 words for feelings", "you could not name"],
    caption:
      "The right word makes the feeling less blurry. #emotionalvocabulary #selfawareness #verbsy",
    title: "feelings you could not name",
    words: [
      {
        word: "disquiet",
        meta: "noun * dis-KWY-et",
        definition: "a low, uneasy sense that something is wrong.",
        example: "Not panic. Just the room feeling off.",
      },
      {
        word: "trepidation",
        meta: "noun * trep-ih-DAY-shun",
        definition: "nervous dread before something happens.",
        example: "The anxiety before the answer arrives.",
      },
      {
        word: "ennui",
        meta: "noun * ahn-WEE",
        definition: "restless boredom with life itself.",
        example: "Nothing is wrong, but nothing feels alive.",
      },
      {
        word: "foreboding",
        meta: "noun * for-BOH-ding",
        definition: "a feeling that something bad is coming.",
        example: "When your body notices before your mind does.",
      },
      {
        word: "rue",
        meta: "verb * ROO",
        definition: "to regret something with bitterness or sorrow.",
        example: "A small choice you keep replaying.",
      },
    ],
  },
  {
    folder: "brain-chemistry-words-001",
    hook: ["3 words that", "permanently altered", "my brain chemistry"],
    caption:
      "These are small words with a long aftertaste. #philosophywords #mindset #verbsy",
    title: "brain chemistry words",
    words: [
      {
        word: "alexithymia",
        meta: "noun * uh-lek-suh-THY-mee-uh",
        definition: "difficulty identifying or describing emotions.",
        example: "Feeling something, but not knowing what.",
      },
      {
        word: "ataraxia",
        meta: "noun * at-uh-RAK-see-uh",
        definition: "calmness that is not easily disturbed.",
        example: "Peace with a backbone.",
      },
      {
        word: "eudaimonia",
        meta: "noun * yoo-dy-MOH-nee-uh",
        definition: "a flourishing life built on meaning and virtue.",
        example: "Not pleasure. A life that feels worthy.",
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

function linesToTspans(lines, { x, size, lineHeight = 1.12 }) {
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
        <rect x="0" y="0" width="1080" height="1920" fill="rgba(248,244,234,0.18)"/>
        <rect x="88" y="472" width="904" height="788" rx="34" fill="rgba(249,246,237,0.78)"/>
        <rect x="88" y="472" width="7" height="788" fill="#7d2935"/>
        <text x="142" y="640" fill="#11110f" font-family="Georgia, Times New Roman, serif" font-size="62" font-weight="750" letter-spacing="0">${linesToTspans(hook, { x: 142, y: 640, size: 62, weight: 750 })}</text>
        <text x="144" y="1078" fill="#47564b" font-family="Arial, Helvetica, sans-serif" font-size="30" font-weight="700" letter-spacing="3">SAVE THIS FOR LATER</text>
        <circle cx="144" cy="1186" r="5" fill="#7d2935"/><circle cx="172" cy="1186" r="5" fill="#7d2935"/><circle cx="200" cy="1186" r="5" fill="#7d2935"/>
      </svg>`
      : `
      <svg width="1080" height="1920" viewBox="0 0 1080 1920" xmlns="http://www.w3.org/2000/svg">
        <rect x="0" y="0" width="1080" height="1920" fill="rgba(248,244,234,0.08)"/>
        <rect x="86" y="390" width="908" height="950" rx="34" fill="rgba(249,246,237,0.82)"/>
        <rect x="86" y="390" width="7" height="950" fill="#7d2935"/>
        <text x="144" y="496" fill="#6f7f72" font-family="Arial, Helvetica, sans-serif" font-size="27" font-weight="800" letter-spacing="3">${String(index).padStart(2, "0")} / ${String(total).padStart(2, "0")}</text>
        <text x="144" y="670" fill="#10100e" font-family="Georgia, Times New Roman, serif" font-size="104" font-weight="750" letter-spacing="0">${escapeXml(item.word)}</text>
        <text x="148" y="742" fill="#3f4a41" font-family="Arial, Helvetica, sans-serif" font-size="34" font-weight="700" letter-spacing="0">${escapeXml(item.meta)}</text>
        <line x1="144" y1="805" x2="414" y2="805" stroke="#7d2935" stroke-width="4"/>
        <text x="144" y="916" fill="#11110f" font-family="Georgia, Times New Roman, serif" font-size="56" font-weight="650" letter-spacing="0">${linesToTspans(wrap(item.definition, 27), { x: 144, y: 916, size: 56, weight: 650, lineHeight: 1.18 })}</text>
        <text x="146" y="1194" fill="#30352f" font-family="Arial, Helvetica, sans-serif" font-size="36" font-weight="650" letter-spacing="0">${linesToTspans(wrap(item.example, 38), { x: 146, y: 1194, size: 36, weight: 650, lineHeight: 1.24 })}</text>
      </svg>`;

  await sharp(basePath)
    .resize(1080, 1920, { fit: "cover" })
    .composite([{ input: Buffer.from(overlay), top: 0, left: 0 }])
    .png({ quality: 95 })
    .toFile(outputPath);
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

  fs.writeFileSync(
    path.join(tiktoksDir, "verbsy-batch-2026-05-15.json"),
    `${JSON.stringify(posts, null, 2)}\n`,
  );

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
    return `2026-05-15 | ${post.folder} | ${hook} | ${words}`;
  });
  fs.writeFileSync(
    conceptPath,
    `${[...new Set([...existingConcepts, ...conceptLines])].join("\n")}\n`,
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
