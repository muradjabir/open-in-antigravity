import AppKit
import Foundation

/// Unsandboxed background helper that handles `antigravity-opener://` URLs and launches the requested Antigravity app.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let targetApps: [String: String] = [
        "ide": "/Applications/Antigravity IDE.app",
        "hub": "/Applications/Antigravity.app"
    ]

    private var didReceiveURLs = false
    private var terminateWorkItem: DispatchWorkItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self, !self.didReceiveURLs else { return }
            NSApp.terminate(nil)
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        didReceiveURLs = true
        for url in urls {
            handleOpenURL(url)
        }
        scheduleTermination()
    }

    private func handleOpenURL(_ url: URL) {
        guard url.scheme == "antigravity-opener",
              url.host == "open",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        let queryItems = components.queryItems ?? []
        let targetKey = queryItems.first(where: { $0.name == "target" })?.value ?? "ide"
        guard let appPath = targetApps[targetKey],
              FileManager.default.fileExists(atPath: appPath) else {
            return
        }

        let paths = queryItems
            .filter { $0.name == "path" }
            .compactMap { $0.value }
            .filter { FileManager.default.fileExists(atPath: $0) }
        guard !paths.isEmpty else { return }

        openPaths(paths, withApplicationAt: appPath)
    }

    private func openPaths(_ paths: [String], withApplicationAt appPath: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-a", appPath] + paths

        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                return
            }
        } catch {
            // Fall back to NSWorkspace if /usr/bin/open cannot be spawned.
        }

        let fileURLs = paths.map { URL(fileURLWithPath: $0) }
        let appURL = URL(fileURLWithPath: appPath)
        NSWorkspace.shared.open(fileURLs, withApplicationAt: appURL, configuration: NSWorkspace.OpenConfiguration())
    }

    private func scheduleTermination() {
        terminateWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            NSApp.terminate(nil)
        }
        terminateWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
