# Verbsy ASC Setup

ASC is the release path for this repo. Fastlane is not used.

## Local Files

- ASC metadata: `../metadata/app-info/en-US.json`, `../metadata/version/1.0/en-US.json`
- Screenshots: `screenshots/en-US/` (`APP_IPHONE_67`, 1320x2868)
- Export options: `ExportOptions.plist`
- App Store Connect app ID: `6781111581`
- App Store version ID: `e255f97e-fcaa-4870-aa6b-1a793b03c605`
- Version localization ID: `fc7ed40c-cf49-43a6-ad25-4247b618e6af`
- Review detail ID: `c71de367-9f76-475c-9291-11c381949e00`
- App bundle ID: `com.moltcorporation.verbsy`
- Widget bundle ID: `com.moltcorporation.verbsy.VerbsyWidget`
- App group: `group.com.moltcorporation.verbsy`

## Current ASC State

- API auth is stored in the macOS keychain as `Verbsy`.
- App record exists as `Verbsy: Daily Vocabulary`.
- Categories are set to Education / Reference.
- Content rights are set to no third-party content.
- Age rating is set to all safe defaults.
- App metadata is uploaded.
- Five `APP_IPHONE_67` screenshots are uploaded.
- Subscription group `Verbsy Pro` exists: `22162598`.
- Monthly subscription exists: `6781112653`, product ID `verbsy.pro.monthly`, $9.99/month, 3-day free trial.
- Annual subscription exists: `6781112613`, product ID `verbsy.pro.annual`, $29.99/year, 3-day free trial.
- Subscription group localization and App Review screenshots are uploaded.
- Review contact is set to Stuart Green, `hello@moltcorporation.com`, `+19174261633`.
- App availability is initialized and available in new territories.

Remaining before submission:

- App Privacy must be completed/published in App Store Connect.
- A signed build still needs to be uploaded and attached.
- Subscriptions are currently available/priced in the USA. If the app remains available worldwide, add subscription availability and pricing for the remaining app territories, or narrow app availability to the USA before first submission.
- Subscription state may show `MISSING_METADATA` until Apple refreshes it; validation shows no app-level blocking subscription errors, but warns when subscription territory coverage is narrower than app availability.

## Login

Create an App Store Connect API key with Admin or App Manager access, then store
it in the macOS keychain:

```bash
asc auth login \
  --name "Verbsy" \
  --key-id "KEY_ID" \
  --issuer-id "ISSUER_ID" \
  --private-key "/absolute/path/AuthKey_KEY_ID.p8" \
  --network

asc auth status --output table
```

## Bundle IDs

```bash
asc bundle-ids create --identifier "com.moltcorporation.verbsy" --name "Verbsy" --platform IOS --output table
asc bundle-ids create --identifier "com.moltcorporation.verbsy.VerbsyWidget" --name "Verbsy Widget" --platform IOS --output table
```

Enable App Groups for both bundle IDs and configure:

```text
group.com.moltcorporation.verbsy
```

Check the installed command shape first:

```bash
asc bundle-ids capabilities --help
```

## App Record

Apple does not provide public API creation for the initial app record. Create it
in App Store Connect after the bundle ID exists:

- Platform: iOS
- Name: Verbsy: Daily Vocabulary
- Primary language: English (U.S.)
- Bundle ID: `com.moltcorporation.verbsy`
- SKU: `verbsy-ios`
- User access: Full Access

Then resolve the app ID:

```bash
asc apps list --bundle-id "com.moltcorporation.verbsy" --output table
export ASC_APP_ID="6781111581"
```

## App Setup

```bash
asc app-setup info set --app "$ASC_APP_ID" --primary-locale "en-US" --privacy-policy-url "https://verbsy.app/privacy" --name "Verbsy: Daily Vocabulary" --subtitle "One smarter word a day"
asc app-setup categories set --app "$ASC_APP_ID" --primary EDUCATION --secondary REFERENCE
asc apps content-rights edit --app "$ASC_APP_ID" --uses-third-party-content=false
asc age-rating edit --app "$ASC_APP_ID" --all-none
asc app-setup availability edit --app "$ASC_APP_ID" --all-territories --available true --available-in-new-territories true
```

If first-time availability cannot be edited yet:

```bash
asc web apps availability create --app "$ASC_APP_ID" --territory "USA" --available-in-new-territories true
```

## Metadata And Screenshots

```bash
asc metadata validate --dir "../metadata" --subscription-app --output table

asc metadata push \
  --app "$ASC_APP_ID" \
  --version "1.0" \
  --platform IOS \
  --dir "../metadata" \
  --dry-run \
  --output table
```

Apply after the dry run looks correct:

```bash
asc metadata push --app "$ASC_APP_ID" --version "1.0" --platform IOS --dir "../metadata"
```

Validate screenshots:

```bash
asc screenshots validate --path "./screenshots/en-US" --device-type "IPHONE_67" --output table
```

```bash
asc screenshots upload --app "$ASC_APP_ID" --version "1.0" --path "./screenshots" --device-type "IPHONE_67"
```

## Subscriptions

One auto-renewable subscription group named `Verbsy Pro`:

- `verbsy.pro.monthly`: $9.99/month, 3-day free trial
- `verbsy.pro.annual`: $29.99/year, 3-day free trial

Validate:

```bash
asc validate subscriptions --app "$ASC_APP_ID" --output table
```

For first review, attach the group if validation says it is ready but not
included:

```bash
asc web review subscriptions list --app "$ASC_APP_ID"
asc web review subscriptions attach-group --app "$ASC_APP_ID" --group-id "GROUP_ID" --confirm
```

## Build And Upload

```bash
asc xcode archive \
  --project "verbsy.xcodeproj" \
  --scheme "verbsy" \
  --configuration Release \
  --clean \
  --archive-path ".asc/artifacts/Verbsy.xcarchive" \
  --xcodebuild-flag=-destination \
  --xcodebuild-flag=generic/platform=iOS \
  --output json

asc xcode export \
  --archive-path ".asc/artifacts/Verbsy.xcarchive" \
  --export-options "ExportOptions.plist" \
  --ipa-path ".asc/artifacts/Verbsy.ipa" \
  --xcodebuild-flag=-allowProvisioningUpdates \
  --output json

asc builds upload --app "$ASC_APP_ID" --ipa ".asc/artifacts/Verbsy.ipa" --wait
```

## Final Validation

```bash
asc apps content-rights edit --app "$ASC_APP_ID" --uses-third-party-content=false

asc validate \
  --app "$ASC_APP_ID" \
  --version "1.0" \
  --platform IOS \
  --strict \
  --output table
```

App Privacy still needs App Store Connect confirmation. Current expected answer:
no data collected and no tracking.

Reviewer note:

```text
No login required. The word feed and quizzes are free. Verbsy Pro unlocks word-of-the-day notifications and Home Screen / Lock Screen widget styles with a 3-day free trial.
```

Review details are already set:

```bash
asc review details-update \
  --id "c71de367-9f76-475c-9291-11c381949e00" \
  --demo-account-required=false \
  --contact-first-name "Stuart" \
  --contact-last-name "Green" \
  --contact-email "hello@moltcorporation.com" \
  --contact-phone "+19174261633" \
  --notes "No login required. The word feed and quizzes are free. Verbsy Pro unlocks word-of-the-day notifications and Home Screen / Lock Screen widget styles with a 3-day free trial."
```
