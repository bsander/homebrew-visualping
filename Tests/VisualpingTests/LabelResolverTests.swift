import XCTest
@testable import VisualpingCore

final class LabelResolverTests: XCTestCase {
    func testNilPathNilLabelReturnsNil() {
        let result = LabelResolver.resolve(path: nil, pathStyle: .short, label: nil)
        XCTAssertNil(result)
    }

    func testLabelOnlyReturnsLabel() {
        let result = LabelResolver.resolve(path: nil, pathStyle: .short, label: "Fix bug")
        XCTAssertEqual(result, "Fix bug")
    }

    func testExplicitPathShortReturnsBasename() {
        let result = LabelResolver.resolve(path: "/Users/sb/src/myapp", pathStyle: .short, label: nil)
        XCTAssertEqual(result, "myapp")
    }

    func testExplicitPathFullReturnsFullPath() {
        let result = LabelResolver.resolve(path: "/Users/sb/src/myapp", pathStyle: .full, label: nil)
        XCTAssertEqual(result, "/Users/sb/src/myapp")
    }

    func testPathAndLabelCombined() {
        let result = LabelResolver.resolve(path: "/foo/bar", pathStyle: .short, label: "Tests pass")
        XCTAssertEqual(result, "bar: Tests pass")
    }

    func testPathFullAndLabelCombined() {
        let result = LabelResolver.resolve(path: "/foo/bar", pathStyle: .full, label: "Done")
        XCTAssertEqual(result, "/foo/bar: Done")
    }

    func testDotPathResolvesToCwdBasename() {
        let result = LabelResolver.resolve(path: ".", pathStyle: .short, label: nil)
        let expected = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).lastPathComponent
        XCTAssertEqual(result, expected)
    }

    func testDotPathFullResolvesToCwdFullPath() {
        let result = LabelResolver.resolve(path: ".", pathStyle: .full, label: nil)
        let expected = FileManager.default.currentDirectoryPath
        XCTAssertEqual(result, expected)
    }

    func testDotPathWithLabelCombined() {
        let result = LabelResolver.resolve(path: ".", pathStyle: .short, label: "hello")
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).lastPathComponent
        XCTAssertEqual(result, "\(cwd): hello")
    }
}
