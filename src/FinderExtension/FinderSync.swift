import AppKit
import FinderSync
import Foundation

/// Sandboxed Finder Sync extension that adds top-level context menu items and delegates launches via URL scheme.
final class FinderSync: FIFinderSync {
    private struct TargetSpec {
        let key: String
        let title: String
        let appPath: String
        let iconResource: String
        let action: Selector
    }

    private lazy var targets: [TargetSpec] = [
        TargetSpec(
            key: "ide",
            title: "Open in Antigravity IDE",
            appPath: "/Applications/Antigravity IDE.app",
            iconResource: "ide",
            action: #selector(openInIDE(_:))
        ),
        TargetSpec(
            key: "hub",
            title: "Open in Antigravity",
            appPath: "/Applications/Antigravity.app",
            iconResource: "hub",
            action: #selector(openInHub(_:))
        )
    ]

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        switch menuKind {
        case .contextualMenuForItems, .contextualMenuForContainer, .contextualMenuForSidebar:
            break
        default:
            return nil
        }

        let available = targets.filter { FileManager.default.fileExists(atPath: $0.appPath) }
        // Fallback so App Sandbox restrictions on /Applications never suppress menu items.
        let activeTargets = available.isEmpty ? targets : available

        let menu = NSMenu(title: "")
        for spec in activeTargets {
            let item = NSMenuItem(title: spec.title, action: spec.action, keyEquivalent: "")
            item.target = self
            item.image = menuIcon(for: spec)
            menu.addItem(item)
        }
        return menu
    }

    @objc func openInIDE(_ sender: AnyObject?) {
        openTarget("ide")
    }

    @objc func openInHub(_ sender: AnyObject?) {
        openTarget("hub")
    }

    private func openTarget(_ target: String) {
        let urls = resolveTargetURLs()
        guard !urls.isEmpty else { return }

        var components = URLComponents()
        components.scheme = "antigravity-opener"
        components.host = "open"
        components.queryItems = [URLQueryItem(name: "target", value: target)]
            + urls.map { URLQueryItem(name: "path", value: $0.path) }

        guard let bridgeURL = components.url else { return }
        NSWorkspace.shared.open(bridgeURL)
    }

    private func resolveTargetURLs() -> [URL] {
        let controller = FIFinderSyncController.default()
        if let selected = controller.selectedItemURLs(), !selected.isEmpty {
            return selected
        }
        if let targeted = controller.targetedURL() {
            return [targeted]
        }
        return []
    }

    private func menuIcon(for spec: TargetSpec) -> NSImage? {
        let bundle = Bundle(for: FinderSync.self)
        let sourceImage = bundle.image(forResource: spec.iconResource)
            ?? NSWorkspace.shared.icon(forFile: spec.appPath)
        guard let resized = sourceImage.copy() as? NSImage else {
            return nil
        }
        resized.size = NSSize(width: 16, height: 16)
        return resized
    }
}
