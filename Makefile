.PHONY: build install uninstall verify clean

EXT_BUNDLE_ID := io.github.muradjabir.open-in-antigravity.findersync
APP_PATH := /Applications/OpenInAntigravity.app

build:
	./scripts/build.sh

install:
	./scripts/install.sh

uninstall:
	./scripts/uninstall.sh

verify:
	plutil -lint src/HostApp/Info.plist src/FinderExtension/Info.plist src/FinderExtension/Extension.entitlements
	lipo -info "$(APP_PATH)/Contents/MacOS/OpenInAntigravity"
	lipo -info "$(APP_PATH)/Contents/PlugIns/AntigravityFinderSync.appex/Contents/MacOS/AntigravityFinderSync"
	codesign --verify --deep --strict --verbose=2 "$(APP_PATH)"
	pluginkit -m -v -i "$(EXT_BUNDLE_ID)"

clean:
	rm -rf build dist
