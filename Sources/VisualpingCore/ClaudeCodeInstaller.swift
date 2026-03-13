import Foundation

public struct ClaudeCodeInstaller {
    private let settingsURL: URL

    public init(settingsURL: URL? = nil) {
        if let settingsURL {
            self.settingsURL = settingsURL
        } else {
            self.settingsURL = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".claude/settings.json")
        }
    }

    public func install() throws {
        let fm = FileManager.default
        let dir = settingsURL.deletingLastPathComponent()
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        var settings: [String: Any] = [:]
        if let data = try? Data(contentsOf: settingsURL),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            settings = json
        }

        var hooks = settings["hooks"] as? [String: Any] ?? [:]

        let hookDefinitions: [(event: String, command: String)] = [
            ("Stop", "visualping done --path ."),
            ("Notification", "visualping attention --path ."),
        ]

        for def in hookDefinitions {
            var eventArray = hooks[def.event] as? [[String: Any]] ?? []

            // Remove any existing visualping entries so we always update to the latest command
            eventArray.removeAll { entry in
                guard let innerHooks = entry["hooks"] as? [[String: Any]] else { return false }
                return innerHooks.contains { h in
                    (h["command"] as? String)?.contains("visualping") == true
                }
            }

            let entry: [String: Any] = [
                "matcher": "",
                "hooks": [
                    [
                        "type": "command",
                        "command": def.command,
                        "async": false,
                    ] as [String: Any]
                ],
            ]
            eventArray.append(entry)
            hooks[def.event] = eventArray
        }

        settings["hooks"] = hooks

        let data = try JSONSerialization.data(
            withJSONObject: settings,
            options: [.prettyPrinted, .sortedKeys]
        )
        try data.write(to: settingsURL, options: .atomic)
    }

    public func uninstall() throws {
        guard let data = try? Data(contentsOf: settingsURL),
              var settings = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return }

        guard var hooks = settings["hooks"] as? [String: Any] else { return }

        for key in hooks.keys {
            guard var eventArray = hooks[key] as? [[String: Any]] else { continue }
            eventArray.removeAll { entry in
                guard let innerHooks = entry["hooks"] as? [[String: Any]] else { return false }
                return innerHooks.contains { h in
                    (h["command"] as? String)?.contains("visualping") == true
                }
            }
            if eventArray.isEmpty {
                hooks.removeValue(forKey: key)
            } else {
                hooks[key] = eventArray
            }
        }

        if hooks.isEmpty {
            settings.removeValue(forKey: "hooks")
        } else {
            settings["hooks"] = hooks
        }

        let output = try JSONSerialization.data(
            withJSONObject: settings,
            options: [.prettyPrinted, .sortedKeys]
        )
        try output.write(to: settingsURL, options: .atomic)
    }
}
