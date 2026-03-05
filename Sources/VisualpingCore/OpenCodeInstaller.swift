import Foundation

public struct OpenCodeInstaller {
    private let pluginURL: URL

    public init(pluginURL: URL? = nil) {
        if let pluginURL {
            self.pluginURL = pluginURL
        } else {
            self.pluginURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .appendingPathComponent(".opencode/plugins/visualping.js")
        }
    }

    private static let pluginContent = """
    export const VisualpingPlugin = async ({ $ }) => {
      return {
        event: async ({ event }) => {
          if (event.type === "session.idle") {
            await $`visualping done`
          } else if (event.type === "permission.asked") {
            await $`visualping attention`
          }
        }
      }
    }
    """

    public func install() throws {
        let fm = FileManager.default
        let dir = pluginURL.deletingLastPathComponent()
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        try Self.pluginContent.write(to: pluginURL, atomically: true, encoding: .utf8)
    }

    public func uninstall() throws {
        let fm = FileManager.default
        guard fm.fileExists(atPath: pluginURL.path) else { return }
        try fm.removeItem(at: pluginURL)
    }
}
