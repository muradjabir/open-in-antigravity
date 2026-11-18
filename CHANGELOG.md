# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-11-18

### Added
- Sandboxed `FIFinderSync` extension (`AntigravityFinderSync.appex`) providing top-level **Open in Antigravity IDE** and **Open in Antigravity** Finder context menu items.
- Unsandboxed `LSUIElement` host helper app (`OpenInAntigravity.app`) handling `antigravity-opener://` URL launches.
- Universal (`arm64` + `x86_64`) build, install, and uninstall scripts (`scripts/build.sh`, `scripts/install.sh`, `scripts/uninstall.sh`) and `Makefile`.
- GitHub Actions CI and Release workflows.
