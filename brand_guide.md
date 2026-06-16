# Verbsy Brand Guide

The single source of truth for Verbsy's visual identity. Apply this across the iOS app, the landing page, and all marketing/content. **Direction: "Sage Scholar."**

## Brand essence

Verbsy is a **premium, soothing, intellectually aspirational** vocabulary app — "a sharper word for every day." It should feel like a beautiful hardback and a quiet study: calm, considered, grown-up. Never childish, gamified-loud, or clinical.

- **Personality:** calm · literary · grounded · precise · warm
- **Feeling to evoke:** growth, balance, quiet confidence
- **Avoid:** rainbow palettes, claymorphism/cartoon, neon, stock "edtech blue," pure-white clinical surfaces, jargon

## Voice & tone

Clear, warm, and precise. Short sentences. Confident, not academic. Aspirational but never condescending. Examples: "A sharper word for every day." · "One word. A clear example. A fast review." · "A daily habit that feels light, not academic."

## Logo

`V` monogram (Playfair/serif) in **Ink** on a continuous-rounded square, with a small **Gold** dot accent at the top-right. Keep generous clear space; never recolor the monogram outside Ink/Paper; never stretch.

---

## Color palette — Sage Scholar

Warm-paper ground + deep ink + a single calming **sage** signature + **gold** reserved for achievement. One signature hue, used sparingly = premium.

### Light mode (primary)

| Token | Hex | Usage |
|---|---|---|
| `paper` (background) | `#FAF8F2` | App/page background (warm, not white) |
| `surface` (card) | `#FFFFFF` | Cards, sheets, raised surfaces |
| `panel` | `#F3F1E9` | Recessed/secondary fills, grouped rows |
| `ink` (foreground) | `#1A1916` | Primary text, logo, structure (not buttons) |
| `muted` | `#6B6A63` | Secondary text, captions, phonetics |
| `line` | `#E7E4D9` | Hairline borders, dividers |
| `sage` (signature/primary) | `#356B52` | Primary CTAs, active nav, links, accents |
| `on-sage` | `#FFFFFF` | Text/icons on sage fills |
| `sage-soft` | `#E4EBE0` | Sage-tinted highlight tiles / selected states |
| `gold` (achievement) | `#BE8A3D` | Streaks, mastery, premium, sparkle accent |
| `gold-soft` | `#F3E9D4` | Gold chip/badge backgrounds |
| `destructive` | `#B3402F` | Errors, destructive actions |

### Dark mode

Warm, desaturated tones — never pure black, never inverted light values. Lighten sage/gold for contrast.

| Token | Hex | Usage |
|---|---|---|
| `paper` | `#14130F` | Background (warm near-black) |
| `surface` | `#1E1C16` | Cards, sheets |
| `panel` | `#26241D` | Recessed fills |
| `ink` | `#F3F1E9` | Primary text (warm off-white) |
| `muted` | `#A4A199` | Secondary text |
| `line` | `#2D2A22` | Borders, dividers |
| `sage` | `#7FB89C` | Primary/accent (lightened) |
| `on-sage` | `#14130F` | Text/icons on sage fills |
| `sage-soft` | `#23302A` | Selected/highlight tiles |
| `gold` | `#D9A85A` | Achievement (lightened) |
| `gold-soft` | `#2E2718` | Gold chip backgrounds |
| `destructive` | `#E08A77` | Errors |

### Color rules

- **Sage is the single action color.** Every primary CTA (filled sage + white text) uses sage so users learn "sage = tap" — this lifts conversion and brand recognition. Ink is reserved for text/structure; gold for achievement. Completed/done states use `sageSoft` fill with sage text (e.g., "Learned Today"). Selection states (chosen plan, active filter) may use ink to stay distinct from actions.
- **One accent at a time.** Sage carries identity; gold means *earned* (streaks, mastery, premium) — never decorative everywhere.
- **Gold is not body text.** It fails contrast on paper. Use for accents, icons, fills (with ink text), and badges only.
- **Sage CTAs use `on-sage` text** (white in light, ink in dark), never gray.
- Always meet **WCAG AA** (4.5:1 body text, 3:1 large/UI). Verify both modes independently.

---

## Implementation tokens

### SwiftUI — `enum VerbsyDesign` (light mode; replace existing values in `ios/verbsy/Views/AppRootView.swift`)

```swift
enum VerbsyDesign {
    static let background = Color(red: 0.980, green: 0.973, blue: 0.949) // #FAF8F2 paper
    static let surface    = Color(red: 1.000, green: 1.000, blue: 1.000) // #FFFFFF card
    static let panel      = Color(red: 0.953, green: 0.945, blue: 0.914) // #F3F1E9
    static let ink        = Color(red: 0.102, green: 0.098, blue: 0.086) // #1A1916
    static let muted      = Color(red: 0.420, green: 0.416, blue: 0.388) // #6B6A63
    static let line       = Color(red: 0.906, green: 0.894, blue: 0.851) // #E7E4D9
    static let sage       = Color(red: 0.208, green: 0.420, blue: 0.322) // #356B52
    static let sageSoft   = Color(red: 0.894, green: 0.922, blue: 0.878) // #E4EBE0
    static let gold       = Color(red: 0.745, green: 0.541, blue: 0.239) // #BE8A3D
    static let goldSoft   = Color(red: 0.953, green: 0.914, blue: 0.831) // #F3E9D4
}
```

> **iOS ships light-first.** Sage Scholar is a warm-paper identity; the skill rates paper-style dark mode as low-fidelity ("inverted only"), so the app is locked to light via `.preferredColorScheme(.light)` (`verbsyApp.swift`). The dark palette above is kept for a future, purpose-built dark theme — implement it by migrating to a SwiftUI asset catalog with light/dark variants per token (and separating text-color tokens from fill-color tokens, since `ink` is currently used for both).
>
> Typography on iOS uses native system fonts that map to the brand: **New York** (`design: .serif`) for vocabulary words and display titles via `VerbsyDesign.display(_:)`, and **San Francisco** (`design: .default`) for all UI/body — the native stand-ins for Playfair Display + Inter (no font bundling required).

### CSS custom properties (`nextjs/app/globals.css`)

```css
:root {
  --paper: #FAF8F2;  --surface: #FFFFFF;  --panel: #F3F1E9;
  --ink: #1A1916;    --muted: #6B6A63;    --line: #E7E4D9;
  --sage: #356B52;   --on-sage: #FFFFFF;  --sage-soft: #E4EBE0;
  --gold: #BE8A3D;   --gold-soft: #F3E9D4; --destructive: #B3402F;
}
@media (prefers-color-scheme: dark) {
  :root {
    --paper: #14130F;  --surface: #1E1C16;  --panel: #26241D;
    --ink: #F3F1E9;    --muted: #A4A199;    --line: #2D2A22;
    --sage: #7FB89C;   --on-sage: #14130F;  --sage-soft: #23302A;
    --gold: #D9A85A;   --gold-soft: #2E2718; --destructive: #E08A77;
  }
}
```

---

## Typography

Canonical premium/editorial pairing.

- **Display / words / headings:** **Playfair Display** (serif). Weights 500–700. Use for the daily word, headlines, and pull-quote examples (italic). On iOS this is the editorial voice; the existing `.rounded` system font is acceptable as a fallback but Playfair is the brand target for the hero word.
- **UI / body:** **Inter** (sans). Weights 400 (body), 500 (labels), 600–700 (buttons/emphasis).
- **Type scale (pt/px):** 11 (eyebrow/label) · 13 (caption) · 15 (body) · 18 (subhead) · 24 (title) · 34 (word) · 44+ (hero).
- Body line-height 1.5–1.6. Eyebrows: 11px, uppercase, letter-spacing ~0.16em, `muted`.
- Tabular figures for stats (streak, learned counts).

Google Fonts: `Playfair Display` + `Inter`.

---

## Form & feel

- **Radius:** continuous/rounded corners — cards 22, buttons 14, chips/badges 999 (pill), logo ~26% of size.
- **Spacing:** 4/8pt rhythm. Section gaps 16/24/32.
- **Elevation:** soft, low-contrast shadows only (e.g. `0 12px 30px -18px rgba(0,0,0,0.18)`). No harsh drop shadows.
- **Borders:** 1px `line` hairlines define most separation; shadows are secondary.
- **Motion:** gentle, 150–300ms, spring/ease-out. One or two animated elements per view. Respect reduced-motion. Subtle press-scale (0.96–0.98) on tappables.
- **Imagery:** SVG/vector icons (Lucide/SF Symbols), consistent stroke ~1.7px. No emoji as structural icons.

## Accessibility (non-negotiable)

- Body text ≥ 4.5:1, large/UI ≥ 3:1 — verified in **both** light and dark.
- Touch targets ≥ 44×44pt; ≥ 8pt spacing between targets.
- Never convey meaning by color alone (pair with icon/text).
- Support Dynamic Type and `prefers-reduced-motion`.
- Visible focus states; one primary CTA per screen.

## Where things live

- iOS tokens: `ios/verbsy/Views/AppRootView.swift` → `enum VerbsyDesign`
- Web tokens: `nextjs/app/globals.css` → `:root`
- Visual reference / direction comparison: `brand-directions.html` (root)
