import XCTest
@testable import VisualpingCore

final class ScreenTargetTests: XCTestCase {
    func testParseMain() {
        XCTAssertEqual(ScreenTarget.parse("main"), .main)
    }

    func testParseAll() {
        XCTAssertEqual(ScreenTarget.parse("all"), .all)
    }

    func testParseNumericIndex() {
        XCTAssertEqual(ScreenTarget.parse("1"), .index(1))
        XCTAssertEqual(ScreenTarget.parse("2"), .index(2))
        XCTAssertEqual(ScreenTarget.parse("10"), .index(10))
    }

    func testParseInvalidReturnsNil() {
        XCTAssertNil(ScreenTarget.parse(""))
        XCTAssertNil(ScreenTarget.parse("primary"))
        XCTAssertNil(ScreenTarget.parse("0"))
        XCTAssertNil(ScreenTarget.parse("-1"))
    }

    func testEquatable() {
        XCTAssertEqual(ScreenTarget.main, ScreenTarget.main)
        XCTAssertEqual(ScreenTarget.all, ScreenTarget.all)
        XCTAssertEqual(ScreenTarget.index(2), ScreenTarget.index(2))
        XCTAssertNotEqual(ScreenTarget.main, ScreenTarget.all)
        XCTAssertNotEqual(ScreenTarget.index(1), ScreenTarget.index(2))
    }
}
