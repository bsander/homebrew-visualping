import XCTest
@testable import VisualpingCore

final class AnimationCacheTests: XCTestCase {
    var cacheDir: URL!
    var cache: AnimationCache!

    override func setUp() {
        cacheDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("animcache-test-\(UUID().uuidString)")
        cache = AnimationCache(cacheDirectory: cacheDir)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: cacheDir)
    }

    func testCacheKeyIsConsistent() {
        let key1 = AnimationCache.cacheKey(for: "https://example.com/anim.json")
        let key2 = AnimationCache.cacheKey(for: "https://example.com/anim.json")
        XCTAssertEqual(key1, key2)
    }

    func testDifferentURLsProduceDifferentKeys() {
        let key1 = AnimationCache.cacheKey(for: "https://example.com/a.json")
        let key2 = AnimationCache.cacheKey(for: "https://example.com/b.json")
        XCTAssertNotEqual(key1, key2)
    }

    func testCachedPathPreservesExtension() {
        let path = cache.cachedPath(for: "https://example.com/animation.lottie")
        XCTAssertTrue(path.hasSuffix(".lottie"))
    }

    func testCachedPathUsesJsonForNoExtension() {
        let path = cache.cachedPath(for: "https://example.com/animation")
        XCTAssertTrue(path.hasSuffix(".json"))
    }

    func testIsCachedReturnsFalseForMissingFile() {
        XCTAssertFalse(cache.isCached(urlString: "https://example.com/anim.json"))
    }

    func testIsCachedReturnsTrueAfterStore() throws {
        let sourceFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("source-\(UUID().uuidString).json")
        try "{}".write(to: sourceFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: sourceFile) }

        let urlString = "https://example.com/anim.json"
        try cache.store(fileAt: sourceFile.path, for: urlString)

        XCTAssertTrue(cache.isCached(urlString: urlString))
        let cached = cache.cachedPath(for: urlString)
        XCTAssertTrue(FileManager.default.fileExists(atPath: cached))
    }
}
