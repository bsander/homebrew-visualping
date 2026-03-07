import Foundation

public struct OpenCodeInstaller {
    let pluginURL: URL

    public init(pluginURL: URL? = nil) {
        if let pluginURL {
            self.pluginURL = pluginURL
        } else {
            self.pluginURL = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".config/opencode/plugins/visualping.js")
        }
    }

    private static let pluginContent = """
    export const VisualpingPlugin = async ({ $ }) => {
      const titles = new Map()
      return {
        event: async ({ event }) => {
          if (event.type === "session.updated") {
            const info = event.properties?.info
            if (info?.id && info?.title) {
              titles.set(info.id, info.title)
            }
            return
          }
          const sessionID = event.properties?.sessionID ?? event.properties?.info?.id
          const title = sessionID ? titles.get(sessionID) : undefined
          const args = ["--path", process.cwd()]
          if (title) args.push("--label", title)
          if (event.type === "session.idle") {
            await $`visualping done ${args}`
          } else if (event.type === "session.error") {
            await $`visualping error ${args}`
          } else if (event.type === "permission.asked") {
            await $`visualping attention ${args}`
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
