import CoreGraphics
import XCTest
@testable import VisualpingCore

final class WindowFrameCalculatorTests: XCTestCase {
    // Standard 1920x1080 screen with origin at (0, 0)
    let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)
    let size: CGFloat = 300

    func testCenterPosition() {
        let frame = calculateWindowFrame(in: screen, position: .center, size: size)
        XCTAssertEqual(frame, CGRect(x: 810, y: 390, width: 300, height: 300))
    }

    func testTopLeftPosition() {
        let frame = calculateWindowFrame(in: screen, position: .topLeft, size: size)
        XCTAssertEqual(frame, CGRect(x: 0, y: 780, width: 300, height: 300))
    }

    func testTopCenterPosition() {
        let frame = calculateWindowFrame(in: screen, position: .topCenter, size: size)
        XCTAssertEqual(frame, CGRect(x: 810, y: 780, width: 300, height: 300))
    }

    func testTopRightPosition() {
        let frame = calculateWindowFrame(in: screen, position: .topRight, size: size)
        XCTAssertEqual(frame, CGRect(x: 1620, y: 780, width: 300, height: 300))
    }

    func testBottomLeftPosition() {
        let frame = calculateWindowFrame(in: screen, position: .bottomLeft, size: size)
        XCTAssertEqual(frame, CGRect(x: 0, y: 0, width: 300, height: 300))
    }

    func testBottomCenterPosition() {
        let frame = calculateWindowFrame(in: screen, position: .bottomCenter, size: size)
        XCTAssertEqual(frame, CGRect(x: 810, y: 0, width: 300, height: 300))
    }

    func testBottomRightPosition() {
        let frame = calculateWindowFrame(in: screen, position: .bottomRight, size: size)
        XCTAssertEqual(frame, CGRect(x: 1620, y: 0, width: 300, height: 300))
    }

    func testCustomSize() {
        let frame = calculateWindowFrame(in: screen, position: .center, size: 500)
        XCTAssertEqual(frame.width, 500)
        XCTAssertEqual(frame.height, 500)
    }

    func testNonStandardScreenOrigin() {
        // Screen offset (e.g., secondary monitor)
        let offsetScreen = CGRect(x: 100, y: 200, width: 1920, height: 1080)
        let frame = calculateWindowFrame(in: offsetScreen, position: .topLeft, size: size)
        XCTAssertEqual(frame, CGRect(x: 100, y: 980, width: 300, height: 300))
    }

    func testZeroSizeScreen() {
        let emptyScreen = CGRect.zero
        let frame = calculateWindowFrame(in: emptyScreen, position: .center, size: size)
        XCTAssertEqual(frame, CGRect(x: -150, y: -150, width: 300, height: 300))
    }
}
