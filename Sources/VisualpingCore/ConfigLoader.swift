import Foundation

public struct ConfigLoader {
    private let configURL: URL

    public init(configURL: URL) {
        self.configURL = configURL
    }

    public init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.configURL = home
            .appendingPathComponent(".config/visualping/config.json")
    }

    public func load() -> [String: String] {
        guard let data = try? Data(contentsOf: configURL),
              let json = try? JSONDecoder().decode(ConfigFile.self, from: data)
        else {
            return [:]
        }
        return json.animations
    }
}

private struct ConfigFile: Decodable {
    let animations: [String: String]
}
