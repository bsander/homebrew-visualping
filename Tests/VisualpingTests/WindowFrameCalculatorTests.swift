import CoreGraphics
import XCTest
@testable import VisualpingCore

final class WindowFrameCalculatorTests: XCTestCase {
    // Standard 1920x1080 screen with origin at (0, 0)
    let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)
    let size: CGFloat = 300

    func testCenterPosition() {
        let frame = WindowFrame.calculate(in: screen, position: .center, size: size)
        XCTAssertEqual(frame, CGRect(x: 810, y: 390, width: 300, height: 300))
    }

    func testTopLeftPosition() {
        let frame = WindowFrame.calculate(in: screen, position: .topLeft, size: size)
        XCTAssertEqual(frame, CGRect(x: 16, y: 764, width: 300, height: 300))
    }

    func testTopCenterPosition() {
        let frame = WindowFrame.calculate(in: screen, position: .topCenter, size: size)
        XCTAssertEqual(frame, CGRect(x: 810, y: 764, width: 300, height: 300))
    }

    func testTopRightPosition() {
        let frame = WindowFrame.calculate(in: screen, position: .topRight, size: size)
        XCTAssertEqual(frame, CGRect(x: 1604, y: 764, width: 300, height: 300))
    }

    func testBottomLeftPosition() {
        let frame = WindowFrame.calculate(in: screen, position: .bottomLeft, size: size)
        XCTAssertEqual(frame, CGRect(x: 16, y: 16, width: 300, height: 300))
    }

    func testBottomCenterPosition() {
        let frame = WindowFrame.calculate(in: screen, position: .bottomCenter, size: size)
        XCTAssertEqual(frame, CGRect(x: 810, y: 16, width: 300, height: 300))
    }

    func testBottomRightPosition() {
        let frame = WindowFrame.calculate(in: screen, position: .bottomRight, size: size)
        XCTAssertEqual(frame, CGRect(x: 1604, y: 16, width: 300, height: 300))
    }

    func testCustomSize() {
        let frame = WindowFrame.calculate(in: screen, position: .center, size: 500)
        XCTAssertEqual(frame.width, 500)
        XCTAssertEqual(frame.height, 500)
    }

    func testNonStandardScreenOrigin() {
        let offsetScreen = CGRect(x: 100, y: 200, width: 1920, height: 1080)
        let frame = WindowFrame.calculate(in: offsetScreen, position: .topLeft, size: size)
        XCTAssertEqual(frame, CGRect(x: 116, y: 964, width: 300, height: 300))
    }

    func testZeroSizeScreen() {
        let emptyScreen = CGRect.zero
        let frame = WindowFrame.calculate(in: emptyScreen, position: .center, size: size)
        XCTAssertEqual(frame, CGRect(x: -150, y: -150, width: 300, height: 300))
    }
}
