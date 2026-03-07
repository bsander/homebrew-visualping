import XCTest
@testable import VisualpingCore

final class ValidationTests: XCTestCase {
    func testParseSizePixels() throws {
        let spec = try SizeParser.parse("150")
        if case .pixels(let px) = spec {
            XCTAssertEqual(px, 150)
        } else {
            XCTFail("Expected pixels")
        }
    }

    func testParseSizePercent() throws {
        let spec = try SizeParser.parse("10%")
        if case .percent(let pct) = spec {
            XCTAssertEqual(pct, 10.0)
        } else {
            XCTFail("Expected percent")
        }
    }

    func testParseSizeFractionalPercent() throws {
        let spec = try SizeParser.parse("7.5%")
        if case .percent(let pct) = spec {
            XCTAssertEqual(pct, 7.5)
        } else {
            XCTFail("Expected percent")
        }
    }

    func testParseSizeInvalidThrows() {
        XCTAssertThrowsError(try SizeParser.parse("0"))
        XCTAssertThrowsError(try SizeParser.parse("-1"))
        XCTAssertThrowsError(try SizeParser.parse("abc"))
        XCTAssertThrowsError(try SizeParser.parse("0%"))
        XCTAssertThrowsError(try SizeParser.parse("-5%"))
    }

    func testValidDuration() {
        XCTAssertNoThrow(try DurationValidator.validate(1.5))
        XCTAssertNoThrow(try DurationValidator.validate(0.1))
    }

    func testInvalidDuration() {
        XCTAssertThrowsError(try DurationValidator.validate(0))
        XCTAssertThrowsError(try DurationValidator.validate(-1))
    }
}
