import Foundation

public struct DefaultsConfig: Decodable, Equatable {
    public let position: String?
    public let size: String?
    public let screen: String?
    public let duration: Double?
    public let fullscreen: Bool?

    public init(
        position: String? = nil,
        size: String? = nil,
        screen: String? = nil,
        duration: Double? = nil,
        fullscreen: Bool? = nil
    ) {
        self.position = position
        self.size = size
        self.screen = screen
        self.duration = duration
        self.fullscreen = fullscreen
    }
}

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
        return json.animations ?? [:]
    }

    public func loadDefaults() -> DefaultsConfig? {
        guard let data = try? Data(contentsOf: configURL),
              let json = try? JSONDecoder().decode(ConfigFile.self, from: data)
        else {
            return nil
        }
        return json.defaults
    }
}

private struct ConfigFile: Decodable {
    let animations: [String: String]?
    let defaults: DefaultsConfig?
}
