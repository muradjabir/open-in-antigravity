# Contributing

Contributions are welcome!

## Prerequisites

- macOS 13 or later
- Xcode Command Line Tools (`xcode-select --install`)

## Local Development

Build the universal (`arm64` + `x86_64`) bundle without installing:

```bash
make build
```

Install locally and test the full lifecycle:

```bash
make uninstall
make install
make verify
```

Smoke-test the URL scheme bridge:

```bash
open -g "antigravity-opener://open?target=ide&path=/tmp"
```

## Before Opening a Pull Request

1. Lint all property lists and entitlements:
   ```bash
   plutil -lint src/HostApp/Info.plist src/FinderExtension/Info.plist src/FinderExtension/Extension.entitlements
   ```
2. Run `shellcheck scripts/*.sh` if `shellcheck` is installed.
3. Confirm `make build` succeeds cleanly with zero warnings.
