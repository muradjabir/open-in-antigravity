---
name: Bug report
about: Report a bug or compatibility issue with Open in Antigravity
title: "[Bug]: "
labels: bug
---

## Describe the Bug
A clear and concise description of what happened.

## Steps to Reproduce
1. Right-click a folder/file in Finder (mention whether it is local or inside iCloud Drive / cloud storage).
2. Observe the context menu or app behavior.

## Expected Behavior
What you expected to happen.

## Environment
- **macOS version**: (output of `sw_vers`)
- **Architecture**: (`uname -m`)
- **Installed Antigravity apps**: (`ls /Applications | grep -i antigravity`)
- **PlugInKit status**:
  ```
  pluginkit -m -v -i io.github.muradjabir.open-in-antigravity.findersync
  ```
- **Code signature status**:
  ```
  codesign --verify --deep --strict --verbose=2 /Applications/OpenInAntigravity.app
  ```
