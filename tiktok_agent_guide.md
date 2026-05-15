# TikTok slideshow agent guide

Verbsy grows through short-form vocabulary content. Each TikTok post lives in its own folder under `tiktoks/` and is made from a sequence of slideshow images plus a caption.

## Folder structure

Create one folder per post:

```text
tiktoks/
  words-that-make-you-sound-smarter-001/
    slide1.png
    slide2.png
    slide3.png
    slide4.png
    caption.txt
```

Use lowercase, hyphenated folder names. Keep slide filenames sequential: `slide1.png`, `slide2.png`, `slide3.png`, etc. `slide1.png` is always the hook.

Track every vocabulary word used in `tiktoks/used-words.txt`. Before making a new post, check that file and avoid duplicate words. After generating a post, append each new vocabulary word in lowercase, one word per line, and keep the list alphabetized.

Track each finished post concept in `tiktoks/used-post-concepts.txt`, one line
per post. Include the date, folder slug, hook, and word set. Reusing a strong
word later is acceptable; repeating an entire hook/topic/word set is not.

## Image generation flow

Use the Moltcorp CLI image tools for visual assets.

1. Generate draft slides in 9:16 portrait ratio with Gemini. Use a 1080x1920 final canvas for TikTok photo mode so slides fill the screen without black bars or avoidable cropping:

```bash
moltcorp generate-image \
  --model google/gemini-3-pro-image \
  --aspect-ratio 9:16 \
  --prompt "<prompt>" \
  --output-file tiktoks/<post-folder>/slide1.png
```

2. Review the draft visually.
3. For text-heavy vocabulary posts, prefer generating one strong 9:16 base slide
   and rendering the hook/word text locally with code. This keeps spelling,
   pronunciations, definitions, and layout consistent. The current local renderer
   is `nextjs/scripts/generate-verbsy-tiktoks.mjs`.
4. Verify the final local file is a PNG or JPG under 20MB at 1080x1920. If the model returns a different 9:16-ish size, normalize the approved slide to a 1080x1920 output before upload.
5. Only after the slides are approved, upscale each image when needed:

```bash
moltcorp generate-image upscale \
  --image-url <generated-image-url> \
  --output-file tiktoks/<post-folder>/slide1.png
```

Do not upscale unreviewed drafts. Upscaling is the final pass for approved images.

## Visual system

Every slide should use an approved 9:16 base slide as the visual foundation.
The base slide creates consistency within a post while allowing the account to
test different visual styles across posts.

Base-slide selection rules:

1. If the operator names a base slide number, use that base slide.
2. If no base slide is specified, choose one approved base slide yourself.
3. All slides in a single post must use the same base slide.
4. When making a batch of posts, either use the operator's requested base slide for the whole batch or rotate base slides between posts. Do not mix base slides inside one post.
5. Early testing should use a small number of posts per base slide so performance can be compared cleanly.

If using image generation for individual slides, prompt the image model to keep
the base-slide background, lighting, palette, and watermark intact, then place
the new slide text on top. If rendering locally, keep the same constraints:
text should be vertically centered, left aligned, and use the same bold
editorial type style across the whole slideshow. Keep generous margins so the
text survives TikTok UI overlays. Use high contrast and large mobile-readable
type, with primary slide text no smaller than roughly 36pt on a 1080x1920
canvas.

The base slide should include a small watermark in the bottom-left corner:

```text
word of the day by
verbsy
```

The watermark should feel intentional and quiet, similar to a publisher mark, not a logo slapped on top. Make `verbsy` clearly larger and more prominent than the `word of the day by` line. Do not include App Store or download CTAs in the base slide; if needed later, make a dedicated final CTA slide for that post.

## Slide format

`slide1.png` is always the hook. Strong hook examples:

- 5 words that make you sound smarter
- Words for feelings you've had but couldn't explain
- Stop saying "very sad"
- 3 powerful words most people don't know
- Words that instantly upgrade your vocabulary

The following slides deliver the payoff: one word per slide, or a short set of related words. Each word slide should include the word and a concise definition. When it fits cleanly, add a small detail line under the word with the part of speech and pronunciation, for example `noun * kuhm-PUHNGK-shuhn` or `adj. * per-spi-KAY-shuhs`. Keep this detail secondary and skip it if the slide starts to feel crowded. Add a short example sentence only when it makes the word easier to feel.

## Word vibe

Choose words that feel rare, precise, emotionally useful, and slightly high-status without sounding like a spelling-bee drill. The best Verbsy words make viewers think: "I have felt that, but I didn't know there was a word for it."

Good categories:

- Emotional precision: words for subtle feelings, inner conflict, social tension, longing, shame, restraint, or desire.
- Social intelligence: words for motives, behavior, manipulation, charm, conflict, and power dynamics.
- Intellectual taste: elegant words that upgrade ordinary speech without feeling academic for its own sake.
- Writerly usefulness: words that are short enough to remember and vivid enough to save.

Example words and directions:

- `bellicosity` — readiness to argue or fight.
- `pococurante` — indifferent, unconcerned.
- `quixotry` — impractical idealism.
- `aposiopesis` — breaking off mid-sentence because emotion takes over.
- `agelast` — someone who never laughs.
- `obnubilate` — to cloud, obscure, or make unclear.
- `callipygian` — having beautifully shaped buttocks; use sparingly because it can pull the brand too far into novelty.
- `punctilious` — extremely attentive to detail and correctness.
- `bumfuzzle` — to confuse or fluster.
- `inverecund` — shameless or immodest.
- `alterity` — the state of being other or different.
- `ambisinister` — awkward with both hands.
- `autoschediastic` — improvised or done offhand.
- `malapert` — boldly disrespectful.
- `mansuetude` — gentleness or mildness.
- `compunction` — guilt or moral unease after doing something wrong.

Avoid making the feed feel like generic SAT prep. The tone is aesthetic, emotionally relatable, and intellectually aspirational.

## Captions

Keep captions short. Use one plain sentence plus 3-5 relevant hashtags.

Example:

```text
For the feelings you could never quite name. #vocabulary #wordoftheday #learnontiktok #communication #verbsy
```

Do not over-explain the post in the caption. The slideshow should carry the content.

Prefer captions that feel short, sweet, and authentic. Use 2-5 relevant hashtags,
not broad filler tags.

## TokPortal scheduling

Use TokPortal carousel posts for both TikTok and Instagram.

- TikTok: `video_type` should be `carousel`; include `carousel_images`,
  `description`, `target_publish_date`, and `tiktok_sound_url`.
- Instagram: `video_type` should be `carousel` and `instagram_content_type`
  should be `reel` for fixed-photo Reels. Include `instagram_audio_name` when a
  sound is requested.
- Do not use generic Instagram `post` carousels for Verbsy slideshow content;
  use Instagram Reels (`instagram_content_type: "reel"`) so the content lands in
  the Reels format.
- TokPortal upload responses include both storage paths and public URLs. If
  configuration rejects storage paths as invalid URLs, retry with the returned
  public URLs; TokPortal will store the final accepted value internally.

## Sound rotation

For TikTok carousel posts, rotate these sound URLs:

- `https://www.tiktok.com/music/snowfall-7043672073613936641`
- `https://www.tiktok.com/music/original-sound-7638927758885669645`
- `https://www.tiktok.com/music/original-sound-7358684089900337925`
- `https://www.tiktok.com/music/Beanie-Piano-Version-7473084138540157701`

For Instagram Reels made through TokPortal, provide the matching audio name
when available:

- `snowfall - Øneheart & reidenshi`
- `Original sound 7638927758885669645`
- `Original sound 7358684089900337925`
- `Beanie - Piano Version - Penguin Piano`
