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
    private lazy var configFile: ConfigFile? = {
        guard let data = try? Data(contentsOf: configURL) else { return nil }
        return try? JSONDecoder().decode(ConfigFile.self, from: data)
    }()

    public init(configURL: URL) {
        self.configURL = configURL
    }

    public init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.configURL = home
            .appendingPathComponent(".config/visualping/config.json")
    }

    public mutating func load() -> [String: String] {
        configFile?.animations ?? [:]
    }

    public mutating func loadDefaults() -> DefaultsConfig? {
        configFile?.defaults
    }
}

private struct ConfigFile: Decodable {
    let animations: [String: String]?
    let defaults: DefaultsConfig?
}
