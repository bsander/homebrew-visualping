import XCTest
@testable import VisualpingCore

final class AnimationFormatTests: XCTestCase {
    func testJsonExtensionDetectsJson() {
        XCTAssertEqual(AnimationFormat.detect(from: "/path/to/animation.json"), .json)
    }

    func testDotLottieExtensionDetectsDotLottie() {
        XCTAssertEqual(AnimationFormat.detect(from: "/path/to/animation.lottie"), .dotLottie)
    }

    func testDetectionIsCaseInsensitive() {
        XCTAssertEqual(AnimationFormat.detect(from: "/path/to/ANIMATION.LOTTIE"), .dotLottie)
        XCTAssertEqual(AnimationFormat.detect(from: "/path/to/ANIMATION.JSON"), .json)
    }

    func testNoExtensionDefaultsToJson() {
        XCTAssertEqual(AnimationFormat.detect(from: "/path/to/animation"), .json)
    }
}
