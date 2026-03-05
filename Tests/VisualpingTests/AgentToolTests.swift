import XCTest
@testable import VisualpingCore

final class AgentToolTests: XCTestCase {
    func testParsesClaude() {
        XCTAssertEqual(AgentTool(rawValue: "claude"), .claude)
    }

    func testParsesOpencode() {
        XCTAssertEqual(AgentTool(rawValue: "opencode"), .opencode)
    }

    func testRejectsUnknown() {
        XCTAssertNil(AgentTool(rawValue: "cursor"))
    }
}
