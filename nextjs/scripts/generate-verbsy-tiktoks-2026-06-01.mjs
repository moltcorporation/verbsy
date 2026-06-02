import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const tiktoksDir = path.join(repoRoot, "tiktoks");

const bases = {
  palm: path.join(tiktoksDir, "base-candidate-palm-dusk.png"),
  ocean: path.join(tiktoksDir, "base-candidate-ocean-twilight.png"),
};

const posts = [
  {
    audience: "verbsy",
    folder: "words-for-social-exhaustion-001",
    base: "palm",
    title: "words for social exhaustion",
    hook: ["3 words for", "social exhaustion"],
    caption:
      "For when people feel heavier than usual. #vocabulary #selfawareness #communication #verbsy",
    words: [
      {
        word: "misanthropy",
        meta: "noun * mis-AN-thruh-pee",
        definition: "a general distrust or dislike of people.",
        example: "Not introversion. More like your patience left the room.",
      },
      {
        word: "asocial",
        meta: "adj. * ay-SOH-shul",
        definition: "not motivated by social interaction.",
        example: "Quiet by preference, not always by fear.",
      },
      {
        word: "world-weary",
        meta: "adj. * WURLD-weer-ee",
        definition: "tired from too much experience or disappointment.",
        example: "When everything feels a little too predictable.",
      },
    ],
  },
  {
    audience: "verbsy",
    folder: "words-for-soft-power-001",
    base: "palm",
    title: "words for soft power",
    hook: ["3 words for", "quiet social power"],
    caption:
      "Quiet influence has its own vocabulary. #socialintelligence #communication #wordchoice #verbsy",
    words: [
      {
        word: "gravitas",
        meta: "noun * GRAV-ih-tahs",
        definition: "seriousness and weight that earns respect.",
        example: "The room gets quieter when they speak.",
      },
      {
        word: "tactful",
        meta: "adj. * TAKT-ful",
        definition: "skilled at saying the right thing without offense.",
        example: "Honest, but not careless with it.",
      },
      {
        word: "diplomatic",
        meta: "adj. * dip-luh-MAT-ik",
        definition: "careful and skillful in handling people.",
        example: "They can disagree without making enemies.",
      },
    ],
  },
  {
    audience: "verbsy",
    folder: "words-for-hidden-resentment-001",
    base: "palm",
    title: "words for hidden resentment",
    hook: ["3 words for", "resentment you", "try to hide"],
    caption:
      "Some feelings leak out sideways. #emotionalvocabulary #selfawareness #psychologywords #verbsy",
    words: [
      {
        word: "umbrage",
        meta: "noun * UM-brij",
        definition: "offense or resentment after feeling insulted.",
        example: "The smile stays, but the mood changes.",
      },
      {
        word: "rancor",
        meta: "noun * RANG-ker",
        definition: "deep bitterness that lasts.",
        example: "Anger after it has had time to harden.",
      },
      {
        word: "sullen",
        meta: "adj. * SUL-en",
        definition: "silently resentful or gloomy.",
        example: "When the quiet is doing the arguing.",
      },
    ],
  },
  {
    audience: "verbsy",
    folder: "words-for-losing-yourself-001",
    base: "palm",
    title: "words for losing yourself",
    hook: ["3 words for", "when you start", "losing yourself"],
    caption:
      "For the moments when your inner life feels unfamiliar. #selfawareness #vocabulary #mindset #verbsy",
    words: [
      {
        word: "estrangement",
        meta: "noun * ih-STRAYNJ-ment",
        definition: "a feeling of distance from someone, something, or yourself.",
        example: "You are there, but not fully with yourself.",
      },
      {
        word: "alienation",
        meta: "noun * ay-lee-uh-NAY-shun",
        definition: "feeling isolated or disconnected.",
        example: "The room is full, and still you feel far away.",
      },
      {
        word: "dissociation",
        meta: "noun * dih-soh-see-AY-shun",
        definition: "feeling detached from your thoughts, body, or surroundings.",
        example: "Like watching your life from a few steps back.",
      },
    ],
  },
  {
    audience: "verbsy",
    folder: "words-for-subtle-jealousy-001",
    base: "palm",
    title: "words for subtle jealousy",
    hook: ["3 words for", "jealousy you would", "never admit"],
    caption:
      "A precise word makes the feeling easier to catch. #emotionalintelligence #wordchoice #verbsy",
    words: [
      {
        word: "envy",
        meta: "noun * EN-vee",
        definition: "pain at someone else having what you want.",
        example: "The compliment that costs you effort.",
      },
      {
        word: "covetous",
        meta: "adj. * KUH-vuh-tus",
        definition: "strongly wanting what belongs to someone else.",
        example: "Desire with a little sharp edge.",
      },
      {
        word: "begrudge",
        meta: "verb * bih-GRUHJ",
        definition: "to resent someone for having or receiving something.",
        example: "You are happy for them, almost.",
      },
    ],
  },
  {
    audience: "vocabmaxx",
    folder: "words-that-make-you-sound-perceptive-001",
    base: "ocean",
    title: "words that make you sound perceptive",
    hook: ["5 words that make", "you sound painfully", "perceptive"],
    caption:
      "For when your point needs to land with precision. #vocabulary #wordchoice #communication #verbsy",
    words: [
      {
        word: "astute",
        meta: "adj. * uh-STOOT",
        definition: "quick to notice and understand what matters.",
        example: "An astute comment makes people pause.",
      },
      {
        word: "percipient",
        meta: "adj. * per-SIP-ee-unt",
        definition: "highly perceptive or observant.",
        example: "You saw the pattern before it became obvious.",
      },
      {
        word: "acuminous",
        meta: "adj. * uh-KYOO-muh-nus",
        definition: "sharp in insight or judgment.",
        example: "Taste, but with a blade behind it.",
      },
      {
        word: "penetrating",
        meta: "adj. * PEN-uh-tray-ting",
        definition: "showing deep insight.",
        example: "The kind of question that exposes the real issue.",
      },
      {
        word: "shrewd",
        meta: "adj. * SHROOD",
        definition: "sharp, practical, and good at reading situations.",
        example: "Smart with the lights on.",
      },
    ],
  },
  {
    audience: "vocabmaxx",
    folder: "words-for-when-the-vibe-shifts-001",
    base: "ocean",
    title: "words for when the vibe shifts",
    hook: ["3 words for when", "the vibe suddenly", "shifts"],
    caption:
      "Some shifts are easier to understand once they have a name. #socialintelligence #vocabulary #verbsy",
    words: [
      {
        word: "frisson",
        meta: "noun * free-SOHN",
        definition: "a sudden thrill or shiver of feeling.",
        example: "When the air changes before anyone says why.",
      },
      {
        word: "tension",
        meta: "noun * TEN-shun",
        definition: "a strained feeling between people or ideas.",
        example: "Nothing happened, but everyone noticed it.",
      },
      {
        word: "portent",
        meta: "noun * POR-tent",
        definition: "a sign that something important may happen.",
        example: "The tiny moment before the story turns.",
      },
    ],
  },
  {
    audience: "vocabmaxx",
    folder: "stop-saying-awkward-001",
    base: "ocean",
    title: "stop saying awkward",
    hook: ["Stop saying", '"awkward"'],
    caption:
      "Awkward has levels. These words are cleaner. #wordchoice #vocabulary #communication #verbsy",
    words: [
      {
        word: "ungainly",
        meta: "adj. * un-GAYN-lee",
        definition: "moving or behaving in an awkward way.",
        example: "Clumsy, but somehow specific.",
      },
      {
        word: "stilted",
        meta: "adj. * STIL-ted",
        definition: "stiff, unnatural, or overly formal.",
        example: "The conversation sounded like a script.",
      },
      {
        word: "maladroit",
        meta: "adj. * mal-uh-DROYT",
        definition: "socially or physically awkward.",
        example: "A polished word for an unpolished moment.",
      },
    ],
  },
  {
    audience: "vocabmaxx",
    folder: "words-for-dangerous-charm-001",
    base: "ocean",
    title: "words for dangerous charm",
    hook: ["3 words for", "dangerous charm"],
    caption:
      "Charm is not always harmless. #psychologywords #socialintelligence #vocabulary #verbsy",
    words: [
      {
        word: "beguiling",
        meta: "adj. * bih-GY-ling",
        definition: "charming in a way that can mislead.",
        example: "Attractive enough to lower your guard.",
      },
      {
        word: "insinuating",
        meta: "adj. * in-SIN-yoo-ay-ting",
        definition: "subtly working into someone's favor or mind.",
        example: "They never push. They seep.",
      },
      {
        word: "seductive",
        meta: "adj. * sih-DUK-tiv",
        definition: "tempting or powerfully attractive.",
        example: "Not just romantic. Ideas can be seductive too.",
      },
    ],
  },
  {
    audience: "vocabmaxx",
    folder: "words-for-overexplaining-yourself-001",
    base: "ocean",
    title: "words for overexplaining yourself",
    hook: ["3 words for", "when you keep", "overexplaining"],
    caption:
      "For when the explanation becomes the anxiety. #communication #selfawareness #wordchoice #verbsy",
    words: [
      {
        word: "circumlocution",
        meta: "noun * sir-kum-loh-KYOO-shun",
        definition: "using too many words to say something simple.",
        example: "Talking around the point because the point feels risky.",
      },
      {
        word: "diffuse",
        meta: "adj. * dih-FYOOS",
        definition: "wordy, unfocused, or spread out.",
        example: "The message had a map, but no destination.",
      },
      {
        word: "apologetic",
        meta: "adj. * uh-pol-uh-JET-ik",
        definition: "showing regret or a need to excuse yourself.",
        example: "When every sentence asks permission to exist.",
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

function tspans(lines, { x, size, lineHeight = 1.1 }) {
  return lines
    .map((line, index) => {
      const dy = index === 0 ? 0 : Math.round(size * lineHeight);
      return `<tspan x="${x}" dy="${dy}">${escapeXml(line)}</tspan>`;
    })
    .join("");
}

function fitHookLines(lines) {
  const longest = Math.max(...lines.map((line) => line.length));
  if (longest > 25 || lines.length >= 4) return 78;
  if (longest > 19 || lines.length === 3) return 86;
  return 96;
}

function fitWordSize(word) {
  if (word.length > 18) return 78;
  if (word.length > 14) return 88;
  if (word.length > 11) return 100;
  return 112;
}

function svgOverlay({ kind, post, item, index, total }) {
  const left = 92;
  const shadow = "rgba(0,0,0,0.42)";
  const glow = "rgba(0,0,0,0.24)";

  if (kind === "hook") {
    const size = fitHookLines(post.hook);
    const blockHeight = post.hook.length * size * 1.08;
    const y = Math.round(960 - blockHeight / 2);
    return `
      <svg width="1080" height="1920" viewBox="0 0 1080 1920" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <linearGradient id="shade" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stop-color="rgba(0,0,0,0.38)"/>
            <stop offset="54%" stop-color="rgba(0,0,0,0.12)"/>
            <stop offset="100%" stop-color="rgba(0,0,0,0.04)"/>
          </linearGradient>
        </defs>
        <rect width="1080" height="1920" fill="url(#shade)"/>
        <text x="${left + 4}" y="${y + 4}" fill="${shadow}" font-family="New York, Georgia, serif" font-size="${size}" font-weight="800" letter-spacing="0">${tspans(post.hook, { x: left + 4, size })}</text>
        <text x="${left}" y="${y}" fill="#fffaf2" font-family="New York, Georgia, serif" font-size="${size}" font-weight="800" letter-spacing="0">${tspans(post.hook, { x: left, size })}</text>
        <text x="${left}" y="${y + blockHeight + 112}" fill="rgba(255,250,242,0.76)" font-family="Arial, Helvetica, sans-serif" font-size="30" font-weight="700" letter-spacing="3">SAVE THIS FOR LATER</text>
        <circle cx="${left}" cy="${y + blockHeight + 188}" r="5" fill="rgba(255,250,242,0.8)"/>
        <circle cx="${left + 28}" cy="${y + blockHeight + 188}" r="5" fill="rgba(255,250,242,0.8)"/>
        <circle cx="${left + 56}" cy="${y + blockHeight + 188}" r="5" fill="rgba(255,250,242,0.8)"/>
      </svg>`;
  }

  const wordSize = fitWordSize(item.word);
  const definition = wrap(item.definition, 28);
  const example = wrap(item.example, 34);
  return `
    <svg width="1080" height="1920" viewBox="0 0 1080 1920" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="shade" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="rgba(0,0,0,0.44)"/>
          <stop offset="58%" stop-color="rgba(0,0,0,0.16)"/>
          <stop offset="100%" stop-color="rgba(0,0,0,0.05)"/>
        </linearGradient>
      </defs>
      <rect width="1080" height="1920" fill="url(#shade)"/>
      <text x="${left}" y="610" fill="rgba(255,250,242,0.72)" font-family="Arial, Helvetica, sans-serif" font-size="28" font-weight="800" letter-spacing="3">${String(index).padStart(2, "0")} / ${String(total).padStart(2, "0")}</text>
      <text x="${left + 4}" y="800" fill="${shadow}" font-family="New York, Georgia, serif" font-size="${wordSize}" font-weight="800" letter-spacing="0">${escapeXml(item.word)}</text>
      <text x="${left}" y="796" fill="#fffaf2" font-family="New York, Georgia, serif" font-size="${wordSize}" font-weight="800" letter-spacing="0">${escapeXml(item.word)}</text>
      <text x="${left}" y="866" fill="rgba(255,250,242,0.78)" font-family="Arial, Helvetica, sans-serif" font-size="32" font-weight="700" letter-spacing="0">${escapeXml(item.meta)}</text>
      <line x1="${left}" y1="930" x2="${left + 250}" y2="930" stroke="rgba(255,250,242,0.82)" stroke-width="4"/>
      <text x="${left + 3}" y="1032" fill="${glow}" font-family="New York, Georgia, serif" font-size="54" font-weight="760" letter-spacing="0">${tspans(definition, { x: left + 3, size: 54, lineHeight: 1.18 })}</text>
      <text x="${left}" y="1028" fill="#fffaf2" font-family="New York, Georgia, serif" font-size="54" font-weight="760" letter-spacing="0">${tspans(definition, { x: left, size: 54, lineHeight: 1.18 })}</text>
      <text x="${left + 2}" y="1264" fill="${glow}" font-family="Arial, Helvetica, sans-serif" font-size="36" font-weight="650" letter-spacing="0">${tspans(example, { x: left + 2, size: 36, lineHeight: 1.24 })}</text>
      <text x="${left}" y="1260" fill="rgba(255,250,242,0.88)" font-family="Arial, Helvetica, sans-serif" font-size="36" font-weight="650" letter-spacing="0">${tspans(example, { x: left, size: 36, lineHeight: 1.24 })}</text>
    </svg>`;
}

async function renderSlide({ post, outputPath, kind, item, index, total }) {
  await sharp(bases[post.base])
    .resize(1080, 1920, { fit: "cover" })
    .composite([{ input: Buffer.from(svgOverlay({ kind, post, item, index, total })), top: 0, left: 0 }])
    .png({ quality: 95 })
    .toFile(outputPath);
}

function updateTrackedFiles() {
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
  fs.writeFileSync(usedPath, `${[...used].sort((a, b) => a.localeCompare(b)).join("\n")}\n`);

  fs.writeFileSync(
    path.join(tiktoksDir, "verbsy-batch-2026-06-01.json"),
    `${JSON.stringify(posts, null, 2)}\n`,
  );

  const conceptPath = path.join(tiktoksDir, "used-post-concepts.txt");
  const existing = fs.existsSync(conceptPath)
    ? fs
        .readFileSync(conceptPath, "utf8")
        .split(/\r?\n/)
        .map((line) => line.trim())
        .filter(Boolean)
    : [];
  const conceptLines = posts.map((post) => {
    const hook = post.hook.join(" ");
    const words = post.words.map((item) => item.word.toLowerCase()).join(", ");
    return `2026-06-01 | ${post.folder} | ${hook} | ${words}`;
  });
  fs.writeFileSync(conceptPath, `${[...new Set([...existing, ...conceptLines])].join("\n")}\n`);
}

async function main() {
  for (const basePath of Object.values(bases)) {
    if (!fs.existsSync(basePath)) throw new Error(`Missing base image: ${basePath}`);
  }

  for (const post of posts) {
    const dir = path.join(tiktoksDir, post.folder);
    fs.mkdirSync(dir, { recursive: true });
    await renderSlide({
      post,
      outputPath: path.join(dir, "slide1.png"),
      kind: "hook",
    });
    for (const [i, item] of post.words.entries()) {
      await renderSlide({
        post,
        outputPath: path.join(dir, `slide${i + 2}.png`),
        kind: "word",
        item,
        index: i + 1,
        total: post.words.length,
      });
    }
    fs.writeFileSync(path.join(dir, "caption.txt"), `${post.caption}\n`);
  }

  updateTrackedFiles();
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
