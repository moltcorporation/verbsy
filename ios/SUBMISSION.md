# Verbsy — App Store submission

The app icon, listing copy, and screenshots are prepared in this repo. Most of
the listing can be pushed to App Store Connect with one fastlane command; the
binary upload and the final "Submit for Review" must be done by you (Apple
gates those on your developer account).

## What's already done
- **App icon** — `verbsy/Assets.xcassets/AppIcon.appiconset/verbsy-app-icon.png` (1024×1024, no alpha). Ships in the build automatically.
- **Listing copy** — `fastlane/metadata/en-US/` (name, subtitle, keywords, description, promotional text, release notes, URLs) + category/copyright.
- **Screenshots** — `fastlane/screenshots/en-US/` (6.9" iPhone).
- **fastlane config** — `Appfile`, `Fastfile` (`upload_listing` lane), `Deliverfile`.

## One-time prerequisites (in App Store Connect / Developer portal)
1. Apple Developer Program membership.
2. An **app record** for bundle id `com.moltcorporation.verbsy` (name "Verbsy").
3. The two **auto-renewable subscriptions**, in one subscription group, each with a **3-day free trial** introductory offer:
   - `verbsy.pro.monthly` — $9.99/month
   - `verbsy.pro.annual` — $29.99/year
4. Your legal pages live and reachable: `verbsy.app/terms`, `/privacy`, `/support`.

## Push the listing (metadata + screenshots)
```bash
brew install fastlane            # if not installed

# Create an App Store Connect API key:
#   ASC → Users and Access → Integrations → App Store Connect API → generate
#   (role: App Manager or Admin). Download the .p8 ONCE; note Key ID + Issuer ID.

cd ios
export ASC_KEY_ID=XXXXXXXXXX
export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
export ASC_KEY_PATH=/absolute/path/AuthKey_XXXXXXXXXX.p8

fastlane ios upload_listing
```
This uploads the name, subtitle, keywords, description, promo text, release
notes, URLs, and screenshots to the 1.0 version. It uploads **no binary** and
does **not** submit for review.

## Upload the build (Xcode — needs your signing)
1. In Xcode, select the `verbsy` target → Signing & Capabilities → your Team.
2. Bump the build number if needed (`CURRENT_PROJECT_VERSION`).
3. Product → Archive → Distribute App → App Store Connect → Upload.
   (Or export the .ipa and use the Transporter app.)

## Finish in App Store Connect
1. Select the uploaded build for the 1.0 version.
2. Confirm metadata + screenshots look right.
3. Set the age rating, attach the two in-app subscriptions to the version.
4. App Privacy questionnaire: **no data collected, no tracking** (the app makes no network calls and stores everything on device).
5. Add a reviewer note: no login required; the feed + quiz are free; Verbsy Pro (widgets + daily-word notifications) offers a 3-day free trial via StoreKit.
6. **Submit for Review.**

## Notes / things only you can do
- I can't generate the ASC API key or click Submit — those need your account.
- The screenshots here are real captures of the app at 6.9". App Store also
  accepts these for the 6.5" slot. Add an iPad set only if you ship iPad.
- Regenerate screenshots anytime with `tools/screenshots.sh` (see that script).
