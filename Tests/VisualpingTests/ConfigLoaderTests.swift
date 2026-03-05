import XCTest
@testable import VisualpingCore

final class ConfigLoaderTests: XCTestCase {
    var tempDir: URL!

    override func setUp() {
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("configloader-test-\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testLoadsValidConfig() throws {
        let configURL = tempDir.appendingPathComponent("config.json")
        let json = """
        {
            "animations": {
                "celebrate": "/path/to/party.json",
                "deploy": "https://example.com/deploy.lottie"
            }
        }
        """
        try json.write(to: configURL, atomically: true, encoding: .utf8)

        let loader = ConfigLoader(configURL: configURL)
        let animations = loader.load()

        XCTAssertEqual(animations["celebrate"], "/path/to/party.json")
        XCTAssertEqual(animations["deploy"], "https://example.com/deploy.lottie")
    }

    func testMissingFileReturnsEmptyDictionary() {
        let configURL = tempDir.appendingPathComponent("nonexistent.json")
        let loader = ConfigLoader(configURL: configURL)
        let animations = loader.load()
        XCTAssertTrue(animations.isEmpty)
    }

    func testMalformedJSONReturnsEmptyDictionary() throws {
        let configURL = tempDir.appendingPathComponent("config.json")
        try "not json".write(to: configURL, atomically: true, encoding: .utf8)

        let loader = ConfigLoader(configURL: configURL)
        let animations = loader.load()
        XCTAssertTrue(animations.isEmpty)
    }

    func testEmptyAnimationsReturnsEmptyDictionary() throws {
        let configURL = tempDir.appendingPathComponent("config.json")
        try """
        { "animations": {} }
        """.write(to: configURL, atomically: true, encoding: .utf8)

        let loader = ConfigLoader(configURL: configURL)
        let animations = loader.load()
        XCTAssertTrue(animations.isEmpty)
    }
}
