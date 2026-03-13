import CoreGraphics
import XCTest
@testable import VisualpingCore

final class PillFrameCalculatorTests: XCTestCase {
    let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)

    // MARK: - Centered animation, pill fits easily

    func testPillCenteredOnAnimation() {
        let animFrame = CGRect(x: 810, y: 390, width: 300, height: 300)
        let pillSize = CGSize(width: 200, height: 30)
        let frame = PillFrame.calculate(
            animationFrame: animFrame, screenFrame: screen,
            pillSize: pillSize, bottomMargin: 4
        )
        // Pill should be horizontally centered on animation
        XCTAssertEqual(frame.midX, animFrame.midX, accuracy: 0.5)
        XCTAssertEqual(frame.size, pillSize)
    }

    // MARK: - Pill wider than animation but fits on screen

    func testPillWiderThanAnimationCenteredOnScreen() {
        let animFrame = CGRect(x: 810, y: 390, width: 300, height: 300)
        let pillSize = CGSize(width: 500, height: 30)
        let frame = PillFrame.calculate(
            animationFrame: animFrame, screenFrame: screen,
            pillSize: pillSize, bottomMargin: 4
        )
        // Still centered on animation since there's room
        XCTAssertEqual(frame.midX, animFrame.midX, accuracy: 0.5)
    }

    // MARK: - Right edge clamping

    func testPillClampedAtRightEdge() {
        // Animation at right edge of screen
        let animFrame = CGRect(x: 1604, y: 16, width: 300, height: 300)
        let pillSize = CGSize(width: 500, height: 30)
        let frame = PillFrame.calculate(
            animationFrame: animFrame, screenFrame: screen,
            pillSize: pillSize, bottomMargin: 4
        )
        // Pill right edge should not exceed screen right edge minus margin
        XCTAssertLessThanOrEqual(frame.maxX, screen.maxX - PillFrame.screenMargin)
        // Pill should still be as close to centered on animation as possible
        XCTAssertEqual(frame.maxX, screen.maxX - PillFrame.screenMargin, accuracy: 0.5)
    }

    // MARK: - Left edge clamping

    func testPillClampedAtLeftEdge() {
        // Animation at left edge of screen
        let animFrame = CGRect(x: 16, y: 16, width: 300, height: 300)
        let pillSize = CGSize(width: 500, height: 30)
        let frame = PillFrame.calculate(
            animationFrame: animFrame, screenFrame: screen,
            pillSize: pillSize, bottomMargin: 4
        )
        // Pill left edge should not go below screen left edge plus margin
        XCTAssertGreaterThanOrEqual(frame.minX, screen.minX + PillFrame.screenMargin)
        XCTAssertEqual(frame.minX, screen.minX + PillFrame.screenMargin, accuracy: 0.5)
    }

    // MARK: - Vertical positioning

    func testPillPositionedAtBottomOfAnimation() {
        let animFrame = CGRect(x: 810, y: 390, width: 300, height: 300)
        let pillSize = CGSize(width: 200, height: 30)
        let bottomMargin: CGFloat = 4
        let frame = PillFrame.calculate(
            animationFrame: animFrame, screenFrame: screen,
            pillSize: pillSize, bottomMargin: bottomMargin
        )
        // Pill top should be just below the animation with a gap
        XCTAssertEqual(frame.maxY, animFrame.minY - bottomMargin, accuracy: 0.5)
    }

    // MARK: - Non-standard screen origin (multi-monitor)

    func testNonStandardScreenOrigin() {
        let offsetScreen = CGRect(x: 1920, y: 0, width: 1920, height: 1080)
        let animFrame = CGRect(x: 3524, y: 16, width: 300, height: 300)
        let pillSize = CGSize(width: 500, height: 30)
        let frame = PillFrame.calculate(
            animationFrame: animFrame, screenFrame: offsetScreen,
            pillSize: pillSize, bottomMargin: 4
        )
        // Should clamp to offset screen's right edge
        XCTAssertLessThanOrEqual(frame.maxX, offsetScreen.maxX - PillFrame.screenMargin)
    }

    // MARK: - Pill exactly fits animation width

    func testPillSameWidthAsAnimation() {
        let animFrame = CGRect(x: 810, y: 390, width: 300, height: 300)
        let pillSize = CGSize(width: 300, height: 30)
        let frame = PillFrame.calculate(
            animationFrame: animFrame, screenFrame: screen,
            pillSize: pillSize, bottomMargin: 4
        )
        XCTAssertEqual(frame.midX, animFrame.midX, accuracy: 0.5)
        XCTAssertEqual(frame.width, 300)
    }

    // MARK: - Bottom edge clamping

    func testPillClampedAtBottomEdge() {
        // Animation at the very bottom of the screen
        let animFrame = CGRect(x: 810, y: 10, width: 300, height: 300)
        let pillSize = CGSize(width: 200, height: 30)
        let frame = PillFrame.calculate(
            animationFrame: animFrame, screenFrame: screen,
            pillSize: pillSize, bottomMargin: 4
        )
        // Pill stays below animation but clamped to screen bottom
        XCTAssertGreaterThanOrEqual(frame.minY, screen.minY + PillFrame.screenMargin)
    }

    // MARK: - Max width capping

    func testPillWidthCappedToScreenWidth() {
        let animFrame = CGRect(x: 810, y: 390, width: 300, height: 300)
        // Pill wants to be wider than the screen
        let pillSize = CGSize(width: 3000, height: 30)
        let frame = PillFrame.calculate(
            animationFrame: animFrame, screenFrame: screen,
            pillSize: pillSize, bottomMargin: 4
        )
        // Width should be capped to screen width minus margins
        XCTAssertLessThanOrEqual(frame.width, screen.width - 2 * PillFrame.screenMargin)
    }
}
