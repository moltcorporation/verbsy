import { neon } from "@neondatabase/serverless";

const words = [
  ["sonder", "Sonder", "SAHN-der", "noun", "The realization that every person has a vivid inner life.", "The sudden awareness that every stranger has a private world as complex and meaningful as your own.", "Walking through the airport, she felt sonder as each face passed with its own hidden story.", "A moment of sonder made the disagreement feel less personal.", "Use it when empathy arrives all at once.", "curious", ["Psychology", "Emotions", "Relationships"], "empathetic"],
  ["lucid", "Lucid", "LOO-sid", "adjective", "Clear, bright, and easy to understand.", "Expressed with clean clarity, especially when an idea could have been confusing.", "His explanation was lucid enough that the whole room relaxed.", "She wanted her writing to sound lucid, not overworked.", "Use it to praise clear thinking, speech, or writing.", "casual", ["Writing", "Communication"], "clear"],
  ["sagacious", "Sagacious", "suh-GAY-shus", "adjective", "Calmly wise and perceptive.", "Showing practical wisdom, sharp judgment, and the ability to see what matters.", "Her sagacious advice cut through the panic without sounding cold.", "A sagacious leader knows when not to react.", "Use it for someone whose judgment feels quietly excellent.", "advanced", ["Philosophy", "Productivity", "Communication"], "steady"],
  ["equanimity", "Equanimity", "ee-kwuh-NIM-uh-tee", "noun", "Mental calm under stress.", "The ability to stay balanced and composed when circumstances become difficult.", "He answered the criticism with surprising equanimity.", "Equanimity is not indifference; it is steadiness.", "Use it for poised calm in pressure.", "advanced", ["Psychology", "Productivity", "Emotions"], "calm"],
  ["perspicuous", "Perspicuous", "per-SPIK-yoo-us", "adjective", "Clearly expressed and easy to follow.", "Transparent in meaning because the language or structure removes confusion.", "The memo was perspicuous without becoming simplistic.", "Her argument became perspicuous after one strong example.", "Use it for exceptionally clear explanations.", "advanced", ["Writing", "Communication"], "precise"],
  ["languor", "Languor", "LANG-guhr", "noun", "A dreamy, pleasant tiredness.", "A soft state of physical or emotional heaviness, often slow and almost luxurious.", "Sunday afternoon settled over the apartment with quiet languor.", "The heat gave the whole city a strange languor.", "Use it for slow, atmospheric tiredness.", "curious", ["Emotions", "Writing"], "soft"],
  ["acedia", "Acedia", "uh-SEE-dee-uh", "noun", "A restless lack of care or motivation.", "A state of spiritual or emotional listlessness where even meaningful things feel hard to begin.", "He mistook acedia for laziness, but it felt heavier than that.", "Acedia made every good habit seem distant.", "Use it when procrastination feels existential.", "advanced", ["Psychology", "Philosophy", "Productivity"], "restless"],
  ["ineffable", "Ineffable", "in-EF-uh-bul", "adjective", "Too great or subtle to put into words.", "So intense, beautiful, strange, or complex that ordinary language cannot fully capture it.", "There was an ineffable comfort in hearing her old street name.", "The painting had an ineffable sadness.", "Use it for feelings that resist explanation.", "curious", ["Emotions", "Writing", "Philosophy"], "mysterious"],
  ["liminal", "Liminal", "LIM-uh-nul", "adjective", "Existing between two states.", "Belonging to a threshold, transition, or in-between moment before something becomes settled.", "Graduation felt liminal: no longer a student, not yet anything else.", "Airports have a liminal quality.", "Use it for thresholds and transitions.", "curious", ["Philosophy", "Emotions", "Writing"], "transitional"],
  ["tacit", "Tacit", "TAS-it", "adjective", "Understood without being directly said.", "Implied by behavior, silence, or context rather than openly expressed.", "Their tacit agreement kept the meeting moving.", "There was a tacit expectation that everyone would stay late.", "Use it for unspoken understanding.", "casual", ["Communication", "Relationships", "Work"], "quiet"],
  ["trenchant", "Trenchant", "TREN-chunt", "adjective", "Sharp, clear, and forceful.", "Expressed with cutting precision, especially in criticism or analysis.", "Her trenchant comment changed the direction of the debate.", "A trenchant edit can save a weak paragraph.", "Use it for sharp insight that lands.", "advanced", ["Writing", "Communication"], "sharp"],
  ["poignant", "Poignant", "POYN-yunt", "adjective", "Deeply touching, often with sadness.", "Emotionally piercing because something feels tender, beautiful, or quietly painful.", "The final line was poignant without being sentimental.", "It was a poignant reminder of how quickly things change.", "Use it for tender emotional impact.", "casual", ["Emotions", "Writing"], "tender"],
  ["resolute", "Resolute", "REZ-uh-loot", "adjective", "Firm and determined.", "Steady in purpose, especially when it would be easier to give up or bend.", "She stayed resolute after the first rejection.", "A resolute tone can calm an uncertain team.", "Use it for determined steadiness.", "casual", ["Productivity", "Communication"], "determined"],
  ["mellifluous", "Mellifluous", "muh-LIF-loo-us", "adjective", "Smooth and pleasant to hear.", "Flowing sweetly, especially used of voices, music, or language.", "His mellifluous voice made the reading feel intimate.", "The sentence was too mellifluous to cut.", "Use it for beautiful sound.", "advanced", ["Writing", "Communication"], "musical"],
  ["fastidious", "Fastidious", "fa-STID-ee-us", "adjective", "Very attentive to detail.", "Careful, exacting, and hard to please because standards are high.", "Her fastidious notes caught errors everyone else missed.", "He was fastidious about the rhythm of each sentence.", "Use it for precise standards.", "curious", ["Work", "Writing", "Productivity"], "exact"],
  ["aplomb", "Aplomb", "uh-PLOM", "noun", "Confident composure.", "Self-possessed confidence, especially in a difficult or public situation.", "She handled the tense question with aplomb.", "Aplomb makes confidence look effortless.", "Use it for graceful confidence under pressure.", "curious", ["Communication", "Work"], "confident"],
  ["insouciant", "Insouciant", "in-SOO-see-unt", "adjective", "Casually unconcerned.", "Relaxed and unworried, sometimes charmingly and sometimes carelessly.", "His insouciant reply made everyone else feel less anxious.", "She walked in with an insouciant ease.", "Use it for effortless nonchalance.", "advanced", ["Emotions", "Communication"], "light"],
  ["discernment", "Discernment", "di-SURN-munt", "noun", "The ability to judge well.", "Careful perception that separates what is useful, true, or important from what is not.", "Good taste begins with discernment.", "Discernment helped her ignore urgent but unimportant tasks.", "Use it for refined judgment.", "curious", ["Philosophy", "Productivity"], "wise"],
  ["candor", "Candor", "KAN-der", "noun", "Honest directness.", "The quality of being open, sincere, and truthful without unnecessary harshness.", "Her candor made the feedback easier to trust.", "Teams move faster when candor feels safe.", "Use it for clean honesty.", "casual", ["Communication", "Relationships", "Work"], "honest"],
  ["solace", "Solace", "SAH-lis", "noun", "Comfort during sadness or difficulty.", "A source of relief, consolation, or quiet emotional support.", "He found solace in a walk after the call.", "The familiar song offered unexpected solace.", "Use it for gentle comfort.", "casual", ["Emotions", "Relationships"], "comforting"],
  ["alacrity", "Alacrity", "uh-LAK-ruh-tee", "noun", "Cheerful readiness.", "A brisk, willing eagerness to do something.", "She accepted the challenge with alacrity.", "His alacrity made the project feel lighter.", "Use it for eager willingness.", "advanced", ["Productivity", "Work"], "energetic"],
  ["nuance", "Nuance", "NOO-ahns", "noun", "A subtle difference in meaning.", "A fine distinction that changes how something should be understood.", "The debate needed more nuance and less certainty.", "A nuanced word can change the emotional temperature.", "Use it for subtle distinctions.", "casual", ["Communication", "Writing", "Philosophy"], "subtle"],
  ["assiduous", "Assiduous", "uh-SIJ-oo-us", "adjective", "Consistent and careful in effort.", "Showing steady attention, diligence, and persistence over time.", "Her assiduous practice made progress almost inevitable.", "Assiduous readers notice what others miss.", "Use it for disciplined consistency.", "advanced", ["Productivity", "Education"], "diligent"],
  ["reverie", "Reverie", "REV-uh-ree", "noun", "A pleasant daydream.", "A dreamy, absorbed state where the mind wanders freely.", "The train ride slipped into reverie.", "He broke from his reverie when the phone buzzed.", "Use it for soft mental drifting.", "curious", ["Emotions", "Writing"], "dreamy"],
  ["eloquence", "Eloquence", "EL-uh-kwents", "noun", "Fluent, persuasive expression.", "The ability to speak or write in a graceful, powerful, and moving way.", "Her eloquence made the idea feel obvious.", "Eloquence is clarity with emotional force.", "Use it for expressive power.", "casual", ["Communication", "Writing"], "expressive"],
  ["abstemious", "Abstemious", "ab-STEE-mee-us", "adjective", "Restrained, especially with indulgence.", "Moderate and self-controlled in habits, pleasures, or consumption.", "His abstemious routine gave him more energy than expected.", "An abstemious approach can be freeing.", "Use it for disciplined restraint.", "advanced", ["Productivity", "Philosophy"], "restrained"],
  ["magnanimous", "Magnanimous", "mag-NAN-uh-mus", "adjective", "Generous and forgiving.", "Noble in spirit, especially toward someone who has less power or has made a mistake.", "Her magnanimous response ended the conflict quickly.", "A magnanimous winner does not humiliate the loser.", "Use it for generous character.", "advanced", ["Relationships", "Philosophy"], "generous"],
  ["cogent", "Cogent", "KOH-junt", "adjective", "Clear, logical, and convincing.", "Persuasive because the reasoning is strong and easy to follow.", "He made a cogent case for changing the plan.", "A cogent paragraph does not need decoration.", "Use it for persuasive clarity.", "curious", ["Writing", "Communication", "Work"], "logical"],
  ["vivacity", "Vivacity", "vi-VAS-uh-tee", "noun", "Lively energy.", "An animated brightness of spirit, expression, or personality.", "Her vivacity changed the mood of the room.", "The essay had intellectual vivacity.", "Use it for lively brightness.", "curious", ["Communication", "Writing"], "bright"],
  ["prosaic", "Prosaic", "proh-ZAY-ik", "adjective", "Ordinary and unimaginative.", "Dull, everyday, or lacking poetic beauty and originality.", "The explanation was accurate but prosaic.", "He turned a prosaic errand into a small adventure.", "Use it for plainness that feels uninspired.", "curious", ["Writing", "Philosophy"], "plain"],
];

const today = new Date();
const dateForOffset = (offset) => {
  const date = new Date(today);
  date.setUTCDate(date.getUTCDate() + offset);
  return date.toISOString().slice(0, 10);
};

if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL is required to seed Verbsy words.");
}

const sql = neon(process.env.DATABASE_URL);

for (const item of words) {
  const [
    slug,
    word,
    pronunciation,
    partOfSpeech,
    shortDefinition,
    longDefinition,
    example,
    secondExample,
    useCase,
    difficulty,
    topics,
    emotionalTone,
  ] = item;

  await sql`
    insert into words (
      slug,
      word,
      pronunciation,
      part_of_speech,
      short_definition,
      long_definition,
      example,
      second_example,
      use_case,
      difficulty,
      topics,
      emotional_tone,
      is_premium
    )
    values (
      ${slug},
      ${word},
      ${pronunciation},
      ${partOfSpeech},
      ${shortDefinition},
      ${longDefinition},
      ${example},
      ${secondExample},
      ${useCase},
      ${difficulty},
      ${topics},
      ${emotionalTone},
      true
    )
    on conflict (slug) do update set
      word = excluded.word,
      pronunciation = excluded.pronunciation,
      part_of_speech = excluded.part_of_speech,
      short_definition = excluded.short_definition,
      long_definition = excluded.long_definition,
      example = excluded.example,
      second_example = excluded.second_example,
      use_case = excluded.use_case,
      difficulty = excluded.difficulty,
      topics = excluded.topics,
      emotional_tone = excluded.emotional_tone,
      updated_at = now()
  `;
}

for (const [index, [slug]] of words.entries()) {
  const rows = await sql`select id from words where slug = ${slug} limit 1`;
  const wordId = rows[0]?.id;
  if (!wordId) continue;

  await sql`
    insert into daily_words (date, word_id, audience_segment)
    values (${dateForOffset(index)}, ${wordId}, 'all')
    on conflict (date, audience_segment) do update set word_id = excluded.word_id
  `;
}

console.log(`Seeded ${words.length} Verbsy words and ${words.length} daily schedule rows.`);
