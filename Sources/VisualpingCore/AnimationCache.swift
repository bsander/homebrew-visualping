import Foundation
import CryptoKit

public struct AnimationCache {
    private let cacheDirectory: URL

    public init(cacheDirectory: URL) {
        self.cacheDirectory = cacheDirectory
    }

    public init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.cacheDirectory = home
            .appendingPathComponent(".config/visualping/cache")
    }

    public static func cacheKey(for urlString: String) -> String {
        let digest = SHA256.hash(data: Data(urlString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    public func cachedPath(for urlString: String) -> String {
        let key = Self.cacheKey(for: urlString)
        let ext = URL(string: urlString)?.pathExtension ?? ""
        let filename = ext.isEmpty ? "\(key).json" : "\(key).\(ext)"
        return cacheDirectory.appendingPathComponent(filename).path
    }

    public func isCached(urlString: String) -> Bool {
        FileManager.default.fileExists(atPath: cachedPath(for: urlString))
    }

    public func store(fileAt sourcePath: String, for urlString: String) throws {
        try FileManager.default.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )
        let dest = cachedPath(for: urlString)
        if FileManager.default.fileExists(atPath: dest) {
            try FileManager.default.removeItem(atPath: dest)
        }
        try FileManager.default.copyItem(atPath: sourcePath, toPath: dest)
    }
}
