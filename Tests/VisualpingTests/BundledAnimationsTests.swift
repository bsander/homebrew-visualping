import XCTest
@testable import VisualpingCore

final class BundledAnimationsTests: XCTestCase {
    func testKnownKeywordReturnsPath() {
        let path = BundledAnimations.path(for: "done")
        XCTAssertNotNil(path)
        XCTAssertTrue(FileManager.default.fileExists(atPath: path!))
    }

    func testAllDefaultKeywordsExist() {
        for keyword in ["done", "error", "attention"] {
            let path = BundledAnimations.path(for: keyword)
            XCTAssertNotNil(path, "Missing bundled animation for '\(keyword)'")
        }
    }

    func testUnknownKeywordReturnsNil() {
        XCTAssertNil(BundledAnimations.path(for: "nonexistent"))
    }

    func testKeywordsListMatchesAvailableResources() {
        let keywords = BundledAnimations.availableKeywords
        XCTAssertEqual(Set(keywords), Set(["done", "error", "attention"]))
    }
}
