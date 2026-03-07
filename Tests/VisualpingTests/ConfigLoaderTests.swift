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

        var loader = ConfigLoader(configURL: configURL)
        let animations = loader.load()

        XCTAssertEqual(animations["celebrate"], "/path/to/party.json")
        XCTAssertEqual(animations["deploy"], "https://example.com/deploy.lottie")
    }

    func testMissingFileReturnsEmptyDictionary() {
        let configURL = tempDir.appendingPathComponent("nonexistent.json")
        var loader = ConfigLoader(configURL: configURL)
        let animations = loader.load()
        XCTAssertTrue(animations.isEmpty)
    }

    func testMalformedJSONReturnsEmptyDictionary() throws {
        let configURL = tempDir.appendingPathComponent("config.json")
        try "not json".write(to: configURL, atomically: true, encoding: .utf8)

        var loader = ConfigLoader(configURL: configURL)
        let animations = loader.load()
        XCTAssertTrue(animations.isEmpty)
    }

    func testEmptyAnimationsReturnsEmptyDictionary() throws {
        let configURL = tempDir.appendingPathComponent("config.json")
        try """
        { "animations": {} }
        """.write(to: configURL, atomically: true, encoding: .utf8)

        var loader = ConfigLoader(configURL: configURL)
        let animations = loader.load()
        XCTAssertTrue(animations.isEmpty)
    }

    // MARK: - Defaults

    func testLoadsDefaultsSection() throws {
        let configURL = tempDir.appendingPathComponent("config.json")
        let json = """
        {
            "animations": {},
            "defaults": {
                "position": "top-right",
                "size": "15%",
                "screen": "all",
                "duration": 2.0,
                "fullscreen": true
            }
        }
        """
        try json.write(to: configURL, atomically: true, encoding: .utf8)

        var loader = ConfigLoader(configURL: configURL)
        let defaults = loader.loadDefaults()

        XCTAssertEqual(defaults?.position, "top-right")
        XCTAssertEqual(defaults?.size, "15%")
        XCTAssertEqual(defaults?.screen, "all")
        XCTAssertEqual(defaults?.duration, 2.0)
        XCTAssertEqual(defaults?.fullscreen, true)
    }

    func testMissingDefaultsSectionReturnsNil() throws {
        let configURL = tempDir.appendingPathComponent("config.json")
        try """
        { "animations": { "done": "/path/to/done.json" } }
        """.write(to: configURL, atomically: true, encoding: .utf8)

        var loader = ConfigLoader(configURL: configURL)
        XCTAssertNil(loader.loadDefaults())
    }

    func testPartialDefaultsSection() throws {
        let configURL = tempDir.appendingPathComponent("config.json")
        let json = """
        {
            "animations": {},
            "defaults": {
                "position": "center",
                "duration": 3.0
            }
        }
        """
        try json.write(to: configURL, atomically: true, encoding: .utf8)

        var loader = ConfigLoader(configURL: configURL)
        let defaults = loader.loadDefaults()

        XCTAssertEqual(defaults?.position, "center")
        XCTAssertNil(defaults?.size)
        XCTAssertNil(defaults?.screen)
        XCTAssertEqual(defaults?.duration, 3.0)
        XCTAssertNil(defaults?.fullscreen)
    }

    func testExistingConfigWithoutDefaultsStillLoadsAnimations() throws {
        let configURL = tempDir.appendingPathComponent("config.json")
        let json = """
        {
            "animations": {
                "celebrate": "/path/to/party.json"
            }
        }
        """
        try json.write(to: configURL, atomically: true, encoding: .utf8)

        var loader = ConfigLoader(configURL: configURL)
        let animations = loader.load()
        XCTAssertEqual(animations["celebrate"], "/path/to/party.json")
        XCTAssertNil(loader.loadDefaults())
    }
}
