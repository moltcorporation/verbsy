#!/bin/bash
# Capture App Store screenshots from the simulator.
# Produces 6.9" iPhone screenshots into ios/fastlane/screenshots/en-US/.
set -e

BUNDLE="com.moltcorporation.verbsy"
DEVICE="${1:-iPhone 16 Pro Max}"   # 6.9" (1320x2868) — an App Store-accepted size
OUT="$(cd "$(dirname "$0")/.." && pwd)/fastlane/screenshots/en-US"
mkdir -p "$OUT"

UDID=$(xcrun simctl list devices available | grep -m1 "$DEVICE (" | grep -oE '[0-9A-F-]{36}')
[ -z "$UDID" ] && { echo "No simulator '$DEVICE'"; exit 1; }
echo "Device: $DEVICE  ($UDID)"

xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 || true

echo "Building…"
cd "$(dirname "$0")/.."
xcodebuild -project verbsy.xcodeproj -scheme verbsy \
  -destination "id=$UDID" -configuration Debug -derivedDataPath /tmp/verbsy_dd \
  build CODE_SIGNING_ALLOWED=NO >/dev/null
APP="/tmp/verbsy_dd/Build/Products/Debug-iphonesimulator/verbsy.app"

xcrun simctl uninstall "$UDID" "$BUNDLE" 2>/dev/null || true
xcrun simctl install "$UDID" "$APP"

shot() { sleep "${2:-2}"; xcrun simctl io "$UDID" screenshot "$OUT/$1.png" >/dev/null; echo "  → $1.png"; }
relaunch() { xcrun simctl terminate "$UDID" "$BUNDLE" 2>/dev/null || true; xcrun simctl launch "$UDID" "$BUNDLE" >/dev/null; }

# 1) Onboarding welcome (fresh state)
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" verbsy.hasCompletedOnboarding -bool false
relaunch; shot "01_onboarding" 3

# Skip onboarding for the in-app screens
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" verbsy.hasCompletedOnboarding -bool true
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" verbsy.localDebugPro -bool true

# 2) Learn feed (hero) — load it first so it records activity
relaunch; sleep 3
xcrun simctl openurl "$UDID" "verbsy://learn"; shot "02_learn" 3
# 3) Home (now shows a streak + a learned word)
xcrun simctl openurl "$UDID" "verbsy://home"; shot "03_home" 2
# 4) Profile
xcrun simctl openurl "$UDID" "verbsy://profile"; shot "04_profile" 2
# 5) Paywall
xcrun simctl openurl "$UDID" "verbsy://paywall"; shot "05_paywall" 3

echo "Done. Screenshots in $OUT"
