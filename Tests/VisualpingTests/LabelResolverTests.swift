import XCTest
@testable import VisualpingCore

final class LabelResolverTests: XCTestCase {
    func testLabelOnly() {
        let result = LabelResolver.resolve(label: "Fix bug")
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).lastPathComponent
        XCTAssertEqual(result, "\(cwd): Fix bug")
    }

    func testNilLabelReturnsProjectFromCwd() {
        let result = LabelResolver.resolve(label: nil)
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).lastPathComponent
        XCTAssertEqual(result, cwd)
    }

    func testDetectsProjectFromCwd() {
        let result = LabelResolver.resolve(label: nil)
        XCTAssertNotNil(result)
        XCTAssertFalse(result!.isEmpty)
    }
}
