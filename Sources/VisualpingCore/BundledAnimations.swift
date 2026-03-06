import Foundation

public enum BundledAnimations {
    public static let availableKeywords = Array(EmbeddedAnimations.animations.keys).sorted()

    private static let cacheDir: URL = {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("visualping-animations")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    public static func path(for keyword: String) -> String? {
        guard let json = EmbeddedAnimations.animations[keyword] else { return nil }
        let file = cacheDir.appendingPathComponent("\(keyword).json")
        if !FileManager.default.fileExists(atPath: file.path) {
            try? json.write(to: file, atomically: true, encoding: .utf8)
        }
        return file.path
    }
}
