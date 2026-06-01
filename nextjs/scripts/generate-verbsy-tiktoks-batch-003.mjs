import fs from "node:fs";
import path from "node:path";
import sharp from "sharp";

const repoRoot = path.resolve(import.meta.dirname, "../..");
const tiktoksDir = path.join(repoRoot, "tiktoks");
const batchDate = "2026-05-15";

const sounds = [
  {
    tiktok: "https://www.tiktok.com/music/snowfall-7043672073613936641",
    instagram: "snowfall - Øneheart & reidenshi",
  },
  {
    tiktok: "https://www.tiktok.com/music/original-sound-7638927758885669645",
    instagram: "Original sound 7638927758885669645",
  },
  {
    tiktok: "https://www.tiktok.com/music/original-sound-7358684089900337925",
    instagram: "Original sound 7358684089900337925",
  },
  {
    tiktok: "https://www.tiktok.com/music/Beanie-Piano-Version-7473084138540157701",
    instagram: "Beanie - Piano Version - Penguin Piano",
  },
];

const posts = [
  {
    accountSet: "verbsy",
    base: "base-candidate-rain-journal.png",
    folder: "words-for-overthinking-at-night-001",
    hook: ["3 words for", "overthinking at night"],
    caption:
      "For the thoughts that get louder after midnight. #emotionalvocabulary #selfawareness #verbsy",
    title: "words for overthinking at night",
    publishDate: "2026-05-23",
    words: [
      {
        word: "rumination",
        meta: "noun * roo-muh-NAY-shuhn",
        definition: "repeatedly thinking about the same worry or regret.",
        example: "When your mind reopens the same tab all night.",
      },
      {
        word: "disquietude",
        meta: "noun * dis-KWY-uh-tood",
        definition: "a restless feeling of worry or unease.",
        example: "Calm on the outside. Static underneath.",
      },
      {
        word: "catastrophize",
        meta: "verb * kuh-TAS-truh-fyze",
        definition: "to imagine the worst possible outcome.",
        example: "A small problem becomes a whole disaster movie.",
      },
    ],
  },
  {
    accountSet: "verbsy",
    base: "base-candidate-rain-journal.png",
    folder: "words-for-reading-the-room-001",
    hook: ["3 words that help you", "read the room"],
    caption:
      "Social intelligence starts with noticing the pattern. #socialintelligence #communication #verbsy",
    title: "words for reading the room",
    publishDate: "2026-05-24",
    words: [
      {
        word: "tact",
        meta: "noun * TAKT",
        definition: "skill at saying the right thing without causing offense.",
        example: "Truth, but with emotional timing.",
      },
      {
        word: "circumspect",
        meta: "adj. * SUR-kum-spekt",
        definition: "careful to consider risks before speaking or acting.",
        example: "You can feel the stakes before you move.",
      },
      {
        word: "rapport",
        meta: "noun * ruh-PORE",
        definition: "a warm, easy connection between people.",
        example: "When the conversation stops feeling like effort.",
      },
    ],
  },
  {
    accountSet: "verbsy",
    base: "base-candidate-rain-journal.png",
    folder: "stop-saying-very-tired-001",
    hook: ["Stop saying", "\"very tired\""],
    caption:
      "Tired is too small for some kinds of exhaustion. #wordchoice #emotionalvocabulary #verbsy",
    title: "stop saying very tired",
    publishDate: "2026-05-25",
    words: [
      {
        word: "enervated",
        meta: "adj. * EN-er-vay-tid",
        definition: "drained of energy or vitality.",
        example: "Not sleepy. Spiritually low-battery.",
      },
      {
        word: "languid",
        meta: "adj. * LANG-gwid",
        definition: "slow, weak, or lacking energy in a graceful way.",
        example: "Tired, but almost poetic about it.",
      },
      {
        word: "spent",
        meta: "adj. * SPENT",
        definition: "completely used up emotionally or physically.",
        example: "When there is nothing left to perform with.",
      },
    ],
  },
  {
    accountSet: "verbsy",
    base: "base-candidate-rain-journal.png",
    folder: "words-for-high-standards-001",
    hook: ["3 words for people", "with high standards"],
    caption:
      "Precision is attractive when it has taste. #mindsetwords #communication #verbsy",
    title: "words for high standards",
    publishDate: "2026-05-26",
    words: [
      {
        word: "fastidious",
        meta: "adj. * fas-TID-ee-us",
        definition: "very attentive to detail and hard to please.",
        example: "They notice what most people miss.",
      },
      {
        word: "discerning",
        meta: "adj. * dih-SUR-ning",
        definition: "able to judge quality with careful taste.",
        example: "Selective because the difference is obvious to them.",
      },
      {
        word: "exacting",
        meta: "adj. * ig-ZAK-ting",
        definition: "requiring great care, precision, or effort.",
        example: "Their standards are not casual.",
      },
    ],
  },
  {
    accountSet: "verbsy",
    base: "base-candidate-rain-journal.png",
    folder: "feelings-after-a-hard-conversation-001",
    hook: ["3 words for after", "a hard conversation"],
    caption:
      "The aftermath has its own vocabulary. #communication #selfawareness #verbsy",
    title: "feelings after a hard conversation",
    publishDate: "2026-05-27",
    words: [
      {
        word: "catharsis",
        meta: "noun * kuh-THAR-sis",
        definition: "emotional release after expressing something difficult.",
        example: "The relief after finally saying it.",
      },
      {
        word: "contrition",
        meta: "noun * kun-TRISH-un",
        definition: "deep regret for something you did wrong.",
        example: "An apology beginning inside the body.",
      },
      {
        word: "closure",
        meta: "noun * KLOH-zher",
        definition: "a sense that something painful has been resolved.",
        example: "Not fixed, but no longer unfinished.",
      },
    ],
  },
  {
    accountSet: "vocabmaxx",
    base: "base-candidate-night-skyline.png",
    folder: "words-that-feel-expensive-001",
    hook: ["5 words that make you", "sound quietly expensive"],
    caption:
      "Tiny words, very different energy. #wordchoice #vocabulary #verbsy",
    title: "words that feel expensive",
    publishDate: "2026-05-28",
    words: [
      {
        word: "urbane",
        meta: "adj. * ur-BAYN",
        definition: "polished, confident, and socially graceful.",
        example: "Smooth without trying to look smooth.",
      },
      {
        word: "refined",
        meta: "adj. * ruh-FYND",
        definition: "elegant, tasteful, and free from roughness.",
        example: "Simple, but clearly chosen.",
      },
      {
        word: "sartorial",
        meta: "adj. * sar-TOR-ee-ul",
        definition: "relating to clothes or personal style.",
        example: "A sartorial detail can change the whole room.",
      },
      {
        word: "suave",
        meta: "adj. * SWAHV",
        definition: "charming, smooth, and confident.",
        example: "Charming, but controlled.",
      },
      {
        word: "cosmopolitan",
        meta: "adj. * koz-muh-POL-ih-tun",
        definition: "worldly, cultured, and at ease in many places.",
        example: "At home in more than one world.",
      },
    ],
  },
  {
    accountSet: "vocabmaxx",
    base: "base-candidate-night-skyline.png",
    folder: "words-for-the-main-character-delusion-001",
    hook: ["3 words for your", "main character delusion"],
    caption:
      "A little delusion deserves better vocabulary. #mindsetwords #vocabulary #verbsy",
    title: "words for the main character delusion",
    publishDate: "2026-05-29",
    words: [
      {
        word: "grandiloquent",
        meta: "adj. * gran-DIL-uh-kwent",
        definition: "using language that sounds overly grand or important.",
        example: "When the group chat becomes a speech.",
      },
      {
        word: "vainglorious",
        meta: "adj. * vayn-GLOR-ee-us",
        definition: "excessively proud of yourself or your achievements.",
        example: "Confidence with a mirror in its hand.",
      },
      {
        word: "quixotic",
        meta: "adj. * kwik-SOT-ik",
        definition: "romantically idealistic in an impractical way.",
        example: "A beautiful plan with no logistics.",
      },
    ],
  },
  {
    accountSet: "vocabmaxx",
    base: "base-candidate-night-skyline.png",
    folder: "words-for-when-someone-is-fake-deep-001",
    hook: ["3 words for when", "someone is fake deep"],
    caption:
      "Some depth is just fog with confidence. #psychologywords #communication #verbsy",
    title: "words for fake deep",
    publishDate: "2026-05-30",
    words: [
      {
        word: "specious",
        meta: "adj. * SPEE-shus",
        definition: "seeming true or wise, but actually misleading.",
        example: "Sounds profound until you touch it.",
      },
      {
        word: "sententious",
        meta: "adj. * sen-TEN-shus",
        definition: "trying too hard to sound morally wise.",
        example: "A quote-post personality in one word.",
      },
      {
        word: "platitudinous",
        meta: "adj. * plat-ih-TOO-din-us",
        definition: "full of dull, overused statements.",
        example: "All lesson, no insight.",
      },
    ],
  },
  {
    accountSet: "vocabmaxx",
    base: "base-candidate-night-skyline.png",
    folder: "words-for-being-too-online-001",
    hook: ["3 words for being", "too online"],
    caption:
      "The internet has a mood, and it is not always healthy. #culturewords #selfawareness #verbsy",
    title: "words for being too online",
    publishDate: "2026-05-31",
    words: [
      {
        word: "reactionary",
        meta: "adj. * ree-AK-shuh-nair-ee",
        definition: "opposing change out of fear or resentment.",
        example: "A whole opinion built from a flinch.",
      },
      {
        word: "performative",
        meta: "adj. * per-FOR-muh-tiv",
        definition: "done mainly to be seen, not sincerely felt.",
        example: "A value performed for applause.",
      },
      {
        word: "polemical",
        meta: "adj. * puh-LEM-ih-kul",
        definition: "strongly argumentative or attacking.",
        example: "Every thought arrives ready to fight.",
      },
    ],
  },
  {
    accountSet: "vocabmaxx",
    base: "base-candidate-night-skyline.png",
    folder: "words-for-not-caring-anymore-001",
    hook: ["3 words for when", "you stop caring"],
    caption:
      "Not every kind of detachment feels the same. #emotionalvocabulary #wordchoice #verbsy",
    title: "words for not caring anymore",
    publishDate: "2026-06-01",
    words: [
      {
        word: "apathetic",
        meta: "adj. * ap-uh-THET-ik",
        definition: "showing little interest, concern, or emotion.",
        example: "When even reacting feels like effort.",
      },
      {
        word: "disenchanted",
        meta: "adj. * dis-en-CHAN-tid",
        definition: "no longer believing in something you once admired.",
        example: "The magic left, and you noticed.",
      },
      {
        word: "blasé",
        meta: "adj. * blah-ZAY",
        definition: "unimpressed because you have seen too much before.",
        example: "Bored, but with experience behind it.",
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

function textBlock(lines, options) {
  return tspans(lines, options);
}

async function renderSlide({ basePath, outputPath, kind, hook, item, index, total }) {
  const accent = "#6d86a2";
  const panel = "rgba(245,241,231,0.91)";
  const ink = "#101214";
  const muted = "#46515d";

  const overlay =
    kind === "hook"
      ? `
      <svg width="1080" height="1920" viewBox="0 0 1080 1920" xmlns="http://www.w3.org/2000/svg">
        <rect x="0" y="0" width="1080" height="1920" fill="rgba(2,5,10,0.20)"/>
        <rect x="82" y="522" width="916" height="704" rx="26" fill="${panel}"/>
        <rect x="82" y="522" width="8" height="704" fill="${accent}"/>
        <text x="142" y="676" fill="${ink}" font-family="Georgia, Times New Roman, serif" font-size="64" font-weight="750" letter-spacing="0">${textBlock(hook, { x: 142, size: 64 })}</text>
        <text x="144" y="1060" fill="${muted}" font-family="Arial, Helvetica, sans-serif" font-size="29" font-weight="800" letter-spacing="3">SAVE THIS WORD SET</text>
        <circle cx="146" cy="1154" r="5" fill="${accent}"/><circle cx="174" cy="1154" r="5" fill="${accent}"/><circle cx="202" cy="1154" r="5" fill="${accent}"/>
      </svg>`
      : `
      <svg width="1080" height="1920" viewBox="0 0 1080 1920" xmlns="http://www.w3.org/2000/svg">
        <rect x="0" y="0" width="1080" height="1920" fill="rgba(2,5,10,0.22)"/>
        <rect x="82" y="388" width="916" height="960" rx="26" fill="${panel}"/>
        <rect x="82" y="388" width="8" height="960" fill="${accent}"/>
        <text x="142" y="500" fill="${muted}" font-family="Arial, Helvetica, sans-serif" font-size="27" font-weight="800" letter-spacing="3">${String(index).padStart(2, "0")} / ${String(total).padStart(2, "0")}</text>
        <text x="142" y="674" fill="${ink}" font-family="Georgia, Times New Roman, serif" font-size="${item.word.length > 13 ? 78 : 96}" font-weight="750" letter-spacing="0">${escapeXml(item.word)}</text>
        <text x="146" y="748" fill="${muted}" font-family="Arial, Helvetica, sans-serif" font-size="33" font-weight="700" letter-spacing="0">${escapeXml(item.meta)}</text>
        <line x1="142" y1="812" x2="414" y2="812" stroke="${accent}" stroke-width="4"/>
        <text x="142" y="924" fill="${ink}" font-family="Georgia, Times New Roman, serif" font-size="51" font-weight="650" letter-spacing="0">${textBlock(wrap(item.definition, 30), { x: 142, size: 51, lineHeight: 1.18 })}</text>
        <text x="146" y="1192" fill="#293037" font-family="Arial, Helvetica, sans-serif" font-size="35" font-weight="650" letter-spacing="0">${textBlock(wrap(item.example, 39), { x: 146, size: 35, lineHeight: 1.24 })}</text>
      </svg>`;

  await sharp(basePath)
    .resize(1080, 1920, { fit: "cover" })
    .composite([{ input: Buffer.from(overlay), top: 0, left: 0 }])
    .png({ quality: 95 })
    .toFile(outputPath);
}

async function main() {
  for (const post of posts) {
    const basePath = path.join(tiktoksDir, post.base);
    if (!fs.existsSync(basePath)) throw new Error(`Missing base image: ${basePath}`);

    const dir = path.join(tiktoksDir, post.folder);
    fs.mkdirSync(dir, { recursive: true });
    await renderSlide({
      basePath,
      outputPath: path.join(dir, "slide1.png"),
      kind: "hook",
      hook: post.hook,
    });
    for (const [i, item] of post.words.entries()) {
      await renderSlide({
        basePath,
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
    const words = post.words.map((entry) => entry.word.toLowerCase()).join(", ");
    return `${batchDate} | ${post.folder} | ${hook} | ${words}`;
  });
  fs.writeFileSync(
    conceptPath,
    `${[...new Set([...existingConcepts, ...conceptLines])].join("\n")}\n`,
  );

  fs.writeFileSync(
    path.join(tiktoksDir, "verbsy-batch-2026-05-15-expansion.json"),
    `${JSON.stringify(
      posts.map((post, index) => ({ ...post, sound: sounds[index % sounds.length] })),
      null,
      2,
    )}\n`,
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
