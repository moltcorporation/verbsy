# Verbsy

Verbsy is a premium vocabulary improvement app focused on one powerful daily word, clean review, local reminders, and paid Home Screen / Lock Screen widgets.

## Repo Layout

- `ios/` contains the native iOS app, Xcode project, StoreKit-facing purchase code, onboarding flow, and WidgetKit extension.
- `nextjs/` contains the Next.js API, Drizzle schema, Neon seed script, Terms, Privacy, and lightweight public web page.
- `tiktoks/` contains short-form content assets and slideshow folders.
- `onboarding_flows_agent_guide.md` and `tiktok_agent_guide.md` stay at the repo root for agent guidance.

## Common Commands

```bash
cd nextjs
npm install
npm run lint
npm run build
npx drizzle-kit push
npm run db:seed
```

```bash
xcodebuild -project ios/verbsy.xcodeproj -scheme verbsy -destination 'generic/platform=iOS Simulator' build
```
