import XCTest
@testable import VisualpingCore

final class AgentTargetTests: XCTestCase {
    func testParsesClaude() {
        XCTAssertEqual(AgentTarget(rawValue: "claude"), .claude)
    }

    func testParsesOpencode() {
        XCTAssertEqual(AgentTarget(rawValue: "opencode"), .opencode)
    }

    func testRejectsUnknown() {
        XCTAssertNil(AgentTarget(rawValue: "cursor"))
    }
}
