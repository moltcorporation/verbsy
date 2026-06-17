#!/bin/bash
# Capture App Store screenshots from the simulator.
# Produces 6.9" iPhone screenshots into ios/screenshots/en-US/.
set -e

BUNDLE="com.moltcorporation.verbsy"
DEVICE="${1:-iPhone 17 Pro Max}"   # 6.9" (1320x2868) — latest installed iPhone, App Store-accepted size
OUT="$(cd "$(dirname "$0")/.." && pwd)/screenshots/en-US"
mkdir -p "$OUT"
rm -f "$OUT"/*.png

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

# Prepare deterministic in-app state for the App Store gallery.
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" verbsy.hasCompletedOnboarding -bool true
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" verbsy.wantsReminders -bool false
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" verbsy.localDebugPro -bool true
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" verbsy.prefs.topics -array "Mind & Ideas" "Words & Communication" "Work & Ambition"
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" verbsy.prefs.difficulties -array casual curious advanced
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" verbsy.prefs.wordsPerDay -int 3
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" verbsy.prefs.reminderHour -int 9
xcrun simctl spawn "$UDID" defaults write "$BUNDLE" verbsy.prefs.reminderMinute -int 0

relaunch; sleep 3

# Ordered for App Store conversion: core experience, differentiators,
# personalization, practice, progress, then pricing transparency.
xcrun simctl openurl "$UDID" "verbsy://learn"; shot "01_learn" 3
xcrun simctl openurl "$UDID" "verbsy://widgets"; shot "02_widgets" 2
xcrun simctl openurl "$UDID" "verbsy://notifications"; shot "03_notifications" 2
xcrun simctl openurl "$UDID" "verbsy://topics"; shot "04_topics" 2
xcrun simctl openurl "$UDID" "verbsy://difficulty"; shot "05_difficulty" 2
xcrun simctl openurl "$UDID" "verbsy://quiz"; shot "06_quiz" 3
xcrun simctl openurl "$UDID" "verbsy://home"; shot "07_home" 2
xcrun simctl openurl "$UDID" "verbsy://paywall"; shot "08_paywall" 3

echo "Done. Screenshots in $OUT"
