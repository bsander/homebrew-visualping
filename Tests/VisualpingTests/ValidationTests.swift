import XCTest
@testable import VisualpingCore

final class ValidationTests: XCTestCase {
    func testValidSizeDoesNotThrow() {
        XCTAssertNoThrow(try validateSize(1))
        XCTAssertNoThrow(try validateSize(300))
        XCTAssertNoThrow(try validateSize(10000))
    }

    func testZeroSizeThrows() {
        XCTAssertThrowsError(try validateSize(0)) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    func testNegativeSizeThrows() {
        XCTAssertThrowsError(try validateSize(-1)) { error in
            XCTAssertTrue(error is ValidationError)
        }
        XCTAssertThrowsError(try validateSize(-100)) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }
}
