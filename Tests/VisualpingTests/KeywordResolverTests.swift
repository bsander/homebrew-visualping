import XCTest
@testable import VisualpingCore

final class KeywordResolverTests: XCTestCase {
    var tempDir: URL!

    override func setUp() {
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("keywordresolver-test-\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testConfigKeywordOverridesBundled() throws {
        let configURL = tempDir.appendingPathComponent("config.json")
        try """
        { "animations": { "done": "/custom/done.json" } }
        """.write(to: configURL, atomically: true, encoding: .utf8)

        let resolver = KeywordResolver(
            configLoader: ConfigLoader(configURL: configURL)
        )
        let result = resolver.resolve("done")

        XCTAssertEqual(result, "/custom/done.json")
    }

    func testBundledKeywordResolves() {
        let resolver = KeywordResolver(
            configLoader: ConfigLoader(configURL: tempDir.appendingPathComponent("missing.json"))
        )
        let result = resolver.resolve("done")

        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("done"))
    }

    func testUnknownKeywordReturnsNil() {
        let resolver = KeywordResolver(
            configLoader: ConfigLoader(configURL: tempDir.appendingPathComponent("missing.json"))
        )
        XCTAssertNil(resolver.resolve("not-a-keyword"))
    }

    func testConfigCustomKeywordResolves() throws {
        let configURL = tempDir.appendingPathComponent("config.json")
        try """
        { "animations": { "deploy": "/path/to/deploy.json" } }
        """.write(to: configURL, atomically: true, encoding: .utf8)

        let resolver = KeywordResolver(
            configLoader: ConfigLoader(configURL: configURL)
        )
        XCTAssertEqual(resolver.resolve("deploy"), "/path/to/deploy.json")
    }

    func testFilePathSourceReturnsNil() {
        let resolver = KeywordResolver(
            configLoader: ConfigLoader(configURL: tempDir.appendingPathComponent("missing.json"))
        )
        XCTAssertNil(resolver.resolve("/path/to/file.json"))
    }

    func testURLSourceReturnsNil() {
        let resolver = KeywordResolver(
            configLoader: ConfigLoader(configURL: tempDir.appendingPathComponent("missing.json"))
        )
        XCTAssertNil(resolver.resolve("https://example.com/anim.json"))
    }
}
