import XCTest
@testable import VisualpingCore

final class ValidationTests: XCTestCase {
    func testParseSizePixels() throws {
        let spec = try parseSize("150")
        if case .pixels(let px) = spec {
            XCTAssertEqual(px, 150)
        } else {
            XCTFail("Expected pixels")
        }
    }

    func testParseSizePercent() throws {
        let spec = try parseSize("10%")
        if case .percent(let pct) = spec {
            XCTAssertEqual(pct, 10.0)
        } else {
            XCTFail("Expected percent")
        }
    }

    func testParseSizeFractionalPercent() throws {
        let spec = try parseSize("7.5%")
        if case .percent(let pct) = spec {
            XCTAssertEqual(pct, 7.5)
        } else {
            XCTFail("Expected percent")
        }
    }

    func testParseSizeInvalidThrows() {
        XCTAssertThrowsError(try parseSize("0"))
        XCTAssertThrowsError(try parseSize("-1"))
        XCTAssertThrowsError(try parseSize("abc"))
        XCTAssertThrowsError(try parseSize("0%"))
        XCTAssertThrowsError(try parseSize("-5%"))
    }

    func testValidDuration() {
        XCTAssertNoThrow(try validateDuration(1.5))
        XCTAssertNoThrow(try validateDuration(0.1))
    }

    func testInvalidDuration() {
        XCTAssertThrowsError(try validateDuration(0))
        XCTAssertThrowsError(try validateDuration(-1))
    }
}
