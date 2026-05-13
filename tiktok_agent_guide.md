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

## Image generation flow

Use the Moltcorp CLI image tools.

1. Generate draft slides in 4:5 aspect ratio with Gemini:

```bash
moltcorp generate-image \
  --model google/gemini-3-pro-image \
  --aspect-ratio 4:5 \
  --prompt "<prompt>" \
  --output-file tiktoks/<post-folder>/slide1.png
```

2. Review the draft slides visually.
3. Only after the slides are approved, upscale each image:

```bash
moltcorp generate-image upscale \
  --image-url <generated-image-url> \
  --output-file tiktoks/<post-folder>/slide1.png
```

Do not upscale unreviewed drafts. Upscaling is the final pass for approved images.

## Visual system

Every slide should use one of the approved base slides as a reference image. The base slide creates consistency within a post while allowing the account to test different visual styles across posts.

Base-slide selection rules:

1. If the operator names a base slide number, use that base slide.
2. If no base slide is specified, choose one approved base slide yourself.
3. All slides in a single post must use the same base slide.
4. When making a batch of posts, either use the operator's requested base slide for the whole batch or rotate base slides between posts. Do not mix base slides inside one post.
5. Early testing should use a small number of posts per base slide so performance can be compared cleanly.

Prompt the image model to keep the base-slide background, lighting, palette, and watermark intact, then place the new slide text on top. Text should be vertically centered, left aligned, and use the same bold editorial type style across the whole slideshow. Keep generous margins so the text survives TikTok cropping.

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
