#!/usr/bin/env bash
set -euo pipefail

APP_PATH="/Applications/OpenInAntigravity.app"
APPEX_PATH="$APP_PATH/Contents/PlugIns/AntigravityFinderSync.appex"
EXT_BUNDLE_ID="io.github.muradjabir.open-in-antigravity.findersync"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

echo "Unregistering Finder Sync extension..."
pluginkit -e ignore -i "$EXT_BUNDLE_ID" 2>/dev/null || true
pluginkit -r "$APPEX_PATH" 2>/dev/null || true
killall AntigravityFinderSync 2>/dev/null || true

if [ -x "$LSREGISTER" ] && [ -d "$APP_PATH" ]; then
    "$LSREGISTER" -u "$APP_PATH" 2>/dev/null || true
fi

rm -rf "$APP_PATH"
echo "Removed ${APP_PATH} and unregistered ${EXT_BUNDLE_ID}."
echo "Run 'killall Finder' if Finder still caches the previous menu item."
