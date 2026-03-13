import XCTest
@testable import VisualpingCore

final class LabelMetricsTests: XCTestCase {
    func testDefaultSizeProducesUnitScale() {
        let m = LabelMetrics(windowHeight: 150)
        XCTAssertEqual(m.fontSize, 13, accuracy: 0.01)
        XCTAssertEqual(m.hPadding, 10, accuracy: 0.01)
        XCTAssertEqual(m.vPadding, 5, accuracy: 0.01)
        XCTAssertEqual(m.cornerRadius, 12, accuracy: 0.01)
        XCTAssertEqual(m.bottomMargin, 4, accuracy: 0.01)
        XCTAssertEqual(m.maxWidthInset, 16, accuracy: 0.01)
    }

    func testSmallWindowClampsToMinimum() {
        let m = LabelMetrics(windowHeight: 50)
        XCTAssertEqual(m.fontSize, 13 * 0.5, accuracy: 0.01)
        XCTAssertEqual(m.cornerRadius, 12 * 0.5, accuracy: 0.01)
    }

    func testLargeWindowClampsToMaximum() {
        let m = LabelMetrics(windowHeight: 1500)
        XCTAssertEqual(m.fontSize, 13 * 3.0, accuracy: 0.01)
        XCTAssertEqual(m.cornerRadius, 12 * 3.0, accuracy: 0.01)
    }

    func testScalesProportionally() {
        let m = LabelMetrics(windowHeight: 450)
        XCTAssertEqual(m.fontSize, 13 * 3.0, accuracy: 0.01)
        XCTAssertEqual(m.hPadding, 10 * 3.0, accuracy: 0.01)
        XCTAssertEqual(m.vPadding, 5 * 3.0, accuracy: 0.01)
    }
}
