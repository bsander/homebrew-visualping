import XCTest
@testable import VisualpingCore

final class LabelResolverTests: XCTestCase {
    func testPathOnly() {
        let result = LabelResolver.resolve(path: "/Users/sb/src/myproject", label: nil)
        XCTAssertEqual(result, "myproject")
    }

    func testLabelOnly() {
        let result = LabelResolver.resolve(path: nil, label: "Fix bug")
        XCTAssertEqual(result, "Fix bug")
    }

    func testBothPathAndLabel() {
        let result = LabelResolver.resolve(path: "/Users/sb/src/myproject", label: "Fix bug")
        XCTAssertEqual(result, "myproject: Fix bug")
    }

    func testNeitherPathNorLabel() {
        let result = LabelResolver.resolve(path: nil, label: nil)
        XCTAssertNil(result)
    }

    func testPathWithTrailingSlash() {
        let result = LabelResolver.resolve(path: "/Users/sb/src/myproject/", label: "Fix bug")
        XCTAssertEqual(result, "myproject: Fix bug")
    }

    func testPathOnlyWithTrailingSlash() {
        let result = LabelResolver.resolve(path: "/Users/sb/src/myproject/", label: nil)
        XCTAssertEqual(result, "myproject")
    }
}
