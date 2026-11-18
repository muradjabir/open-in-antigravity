#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="/Applications/OpenInAntigravity.app"
APPEX_PATH="$APP_PATH/Contents/PlugIns/AntigravityFinderSync.appex"
EXT_BUNDLE_ID="io.github.muradjabir.open-in-antigravity.findersync"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

if ! xcode-select -p >/dev/null 2>&1; then
    echo "Error: Xcode Command Line Tools are not installed." >&2
    echo "Install them first by running: xcode-select --install" >&2
    exit 1
fi

"$ROOT_DIR/scripts/build.sh"

echo "Installing to ${APP_PATH}..."
pluginkit -e ignore -i "$EXT_BUNDLE_ID" 2>/dev/null || true
if [ -d "$APP_PATH" ]; then
    pluginkit -r "$APPEX_PATH" 2>/dev/null || true
    rm -rf "$APP_PATH"
fi

cp -R "$ROOT_DIR/build/OpenInAntigravity.app" "$APP_PATH"

if [ -x "$LSREGISTER" ]; then
    "$LSREGISTER" -f "$APP_PATH"
fi

open -g "$APP_PATH"
sleep 1
pluginkit -a "$APPEX_PATH"
pluginkit -e use -i "$EXT_BUNDLE_ID"

echo "Plugin registration status:"
pluginkit -m -v -i "$EXT_BUNDLE_ID"
echo ""
echo "Installation complete. If the menu item does not appear immediately in Finder, run: killall Finder"
