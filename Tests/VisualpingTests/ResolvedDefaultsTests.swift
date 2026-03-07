import XCTest
@testable import VisualpingCore

final class ResolvedDefaultsTests: XCTestCase {
    func testCLIOverridesConfig() {
        let config = DefaultsConfig(
            position: "top-right",
            size: "15%",
            screen: "all",
            duration: 3.0,
            fullscreen: true
        )
        let resolved = ResolvedDefaults(
            cliPosition: .center,
            cliSize: "20%",
            cliScreen: .main,
            cliDuration: 1.0,
            cliFullscreen: false,
            config: config
        )

        XCTAssertEqual(resolved.position, .center)
        XCTAssertEqual(resolved.size, "20%")
        XCTAssertEqual(resolved.screen, .main)
        XCTAssertEqual(resolved.duration, 1.0)
        XCTAssertEqual(resolved.fullscreen, false)
    }

    func testConfigOverridesHardcoded() {
        let config = DefaultsConfig(
            position: "top-right",
            size: "15%",
            screen: "all",
            duration: 3.0,
            fullscreen: true
        )
        let resolved = ResolvedDefaults(
            cliPosition: nil,
            cliSize: nil,
            cliScreen: nil,
            cliDuration: nil,
            cliFullscreen: nil,
            config: config
        )

        XCTAssertEqual(resolved.position, .topRight)
        XCTAssertEqual(resolved.size, "15%")
        XCTAssertEqual(resolved.screen, .all)
        XCTAssertEqual(resolved.duration, 3.0)
        XCTAssertEqual(resolved.fullscreen, true)
    }

    func testAllNilFallsToHardcoded() {
        let resolved = ResolvedDefaults(
            cliPosition: nil,
            cliSize: nil,
            cliScreen: nil,
            cliDuration: nil,
            cliFullscreen: nil,
            config: nil
        )

        XCTAssertEqual(resolved.position, .topRight)
        XCTAssertEqual(resolved.size, "10%")
        XCTAssertEqual(resolved.screen, .main)
        XCTAssertNil(resolved.duration)
        XCTAssertEqual(resolved.fullscreen, false)
    }

    func testInvalidConfigValuesIgnored() {
        let config = DefaultsConfig(
            position: "not-a-position",
            size: nil,
            screen: "invalid",
            duration: nil,
            fullscreen: nil
        )
        let resolved = ResolvedDefaults(
            cliPosition: nil,
            cliSize: nil,
            cliScreen: nil,
            cliDuration: nil,
            cliFullscreen: nil,
            config: config
        )

        XCTAssertEqual(resolved.position, .topRight)
        XCTAssertEqual(resolved.screen, .main)
    }
}
