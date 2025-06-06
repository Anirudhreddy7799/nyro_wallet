#!/usr/bin/env bash
set -e

# Adjust these variables as needed:
IPA_PATH="build/ios/ipa/Runner.ipa"
IOS_APP_ID="1:657462833760:ios:2fe8ab77eb1ea95ba4c905"       # Firebase App ID
RELEASE_NOTES="v01"      # Update per build
TESTERS="anirudh.kalvala@gmail.com"   # Comma-separated tester emails
GROUPS="IOS_mobileTesters"                         # Optional group aliases

# Verify the IPA exists:
if [[ ! -f "$IPA_PATH" ]]; then
  echo "❌ ERROR: Could not find IPA at $IPA_PATH"
  exit 1
fi

# Upload to Firebase App Distribution:
firebase appdistribution:distribute "$IPA_PATH" \
  --app "$IOS_APP_ID" \
  --release-notes "$RELEASE_NOTES" \
  --testers "$TESTERS" \
  --groups "$GROUPS"

echo "✅ Successfully uploaded $IPA_PATH to Firebase App Distribution."
