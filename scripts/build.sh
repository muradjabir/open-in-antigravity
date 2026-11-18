#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SIGN_IDENTITY="${SIGN_IDENTITY:--}"
BUILD_UNIVERSAL="${BUILD_UNIVERSAL:-1}"

APP_BUNDLE="build/OpenInAntigravity.app"
APPEX_BUNDLE="$APP_BUNDLE/Contents/PlugIns/AntigravityFinderSync.appex"

compile_binary() {
    local name="$1"
    local output_path="$2"
    shift 2

    if [ "$BUILD_UNIVERSAL" = "1" ]; then
        local arm_bin="build/${name}-arm64"
        local x86_bin="build/${name}-x86_64"
        swiftc -O -swift-version 5 -target arm64-apple-macos13.0 "$@" -o "$arm_bin"
        swiftc -O -swift-version 5 -target x86_64-apple-macos13.0 "$@" -o "$x86_bin"
        lipo -create "$arm_bin" "$x86_bin" -output "$output_path"
        rm -f "$arm_bin" "$x86_bin"
    else
        swiftc -O -swift-version 5 "$@" -o "$output_path"
    fi
}

rm -rf build
mkdir -p \
    "$APP_BUNDLE/Contents/MacOS" \
    "$APP_BUNDLE/Contents/Resources" \
    "$APPEX_BUNDLE/Contents/MacOS" \
    "$APPEX_BUNDLE/Contents/Resources"

echo "Compiling HostApp (BUILD_UNIVERSAL=${BUILD_UNIVERSAL})..."
compile_binary "OpenInAntigravity" \
    "$APP_BUNDLE/Contents/MacOS/OpenInAntigravity" \
    -framework AppKit -framework Foundation \
    src/HostApp/main.swift

echo "Compiling FinderExtension (BUILD_UNIVERSAL=${BUILD_UNIVERSAL})..."
compile_binary "AntigravityFinderSync" \
    "$APPEX_BUNDLE/Contents/MacOS/AntigravityFinderSync" \
    -parse-as-library -module-name AntigravityFinderSync \
    -Xlinker -e -Xlinker _NSExtensionMain \
    -Xlinker -application_extension \
    -framework FinderSync -framework AppKit -framework Foundation \
    src/FinderExtension/FinderSync.swift

cp src/HostApp/Info.plist "$APP_BUNDLE/Contents/Info.plist"
cp src/FinderExtension/Info.plist "$APPEX_BUNDLE/Contents/Info.plist"

IDE_ICON="/Applications/Antigravity IDE.app/Contents/Resources/Antigravity IDE.icns"
HUB_ICON="/Applications/Antigravity.app/Contents/Resources/icon.icns"

if [ -f "$IDE_ICON" ]; then
    cp "$IDE_ICON" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
    cp "$IDE_ICON" "$APPEX_BUNDLE/Contents/Resources/ide.icns"
fi

if [ -f "$HUB_ICON" ]; then
    cp "$HUB_ICON" "$APPEX_BUNDLE/Contents/Resources/hub.icns"
fi

# Strip extended attributes so copied resources do not break codesign resource sealing.
xattr -cr "$APP_BUNDLE"

echo "Signing bundles inside-out with identity '${SIGN_IDENTITY}'..."
codesign --force --sign "$SIGN_IDENTITY" \
    --entitlements src/FinderExtension/Extension.entitlements \
    "$APPEX_BUNDLE"

codesign --force --sign "$SIGN_IDENTITY" \
    "$APP_BUNDLE"

codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
echo "Built and signed $APP_BUNDLE"
