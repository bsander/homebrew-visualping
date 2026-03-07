import Foundation

public struct KeywordResolver {
    private var configLoader: ConfigLoader

    public init(configLoader: ConfigLoader = ConfigLoader()) {
        self.configLoader = configLoader
    }

    /// Resolves a keyword to an animation source string (file path or URL).
    /// Returns nil if the source is not a keyword (i.e., it's already a path or URL).
    public mutating func resolve(_ source: String) -> String? {
        // Skip sources that look like file paths or URLs
        if source.contains("/") || source.contains("\\") ||
           source.hasPrefix("http://") || source.hasPrefix("https://") {
            return nil
        }

        // Check user config first (overrides bundled defaults)
        let config = configLoader.load()
        if let configSource = config[source] {
            return configSource
        }

        // Check bundled defaults
        return BundledAnimations.path(for: source)
    }
}
