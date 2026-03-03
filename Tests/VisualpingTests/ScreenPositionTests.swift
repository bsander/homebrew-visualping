import XCTest
@testable import VisualpingCore

final class ScreenPositionTests: XCTestCase {
    func testAllRawValuesParse() {
        let cases: [(String, ScreenPosition)] = [
            ("center", .center),
            ("top-left", .topLeft),
            ("top-center", .topCenter),
            ("top-right", .topRight),
            ("bottom-left", .bottomLeft),
            ("bottom-center", .bottomCenter),
            ("bottom-right", .bottomRight),
        ]
        for (rawValue, expected) in cases {
            XCTAssertEqual(
                ScreenPosition(rawValue: rawValue), expected,
                "Failed to parse '\(rawValue)'"
            )
        }
    }

    func testCaseIterableCountIsSeven() {
        XCTAssertEqual(ScreenPosition.allCases.count, 7)
    }

    func testInvalidRawValueReturnsNil() {
        XCTAssertNil(ScreenPosition(rawValue: "invalid"))
        XCTAssertNil(ScreenPosition(rawValue: ""))
        XCTAssertNil(ScreenPosition(rawValue: "Center"))
    }
}
