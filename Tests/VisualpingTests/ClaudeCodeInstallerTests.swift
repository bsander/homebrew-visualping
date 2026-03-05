import XCTest
@testable import VisualpingCore

final class ClaudeCodeInstallerTests: XCTestCase {
    var tempDir: URL!
    var settingsURL: URL!
    var installer: ClaudeCodeInstaller!

    override func setUp() {
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        settingsURL = tempDir.appendingPathComponent("settings.json")
        installer = ClaudeCodeInstaller(settingsURL: settingsURL)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testInstallCreatesFileWhenMissing() throws {
        try installer.install()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]
        XCTAssertNotNil(hooks["Stop"])
        XCTAssertNotNil(hooks["Notification"])
        XCTAssertNotNil(hooks["PermissionRequest"])
    }

    func testInstallPreservesExistingSettings() throws {
        let existing = """
        {"customKey": "customValue"}
        """
        try existing.write(to: settingsURL, atomically: true, encoding: .utf8)

        try installer.install()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(json["customKey"] as? String, "customValue")
        XCTAssertNotNil(json["hooks"])
    }

    func testInstallPreservesExistingHooks() throws {
        let existing = """
        {"hooks":{"Stop":[{"matcher":"","hooks":[{"type":"command","command":"echo hi"}]}]}}
        """
        try existing.write(to: settingsURL, atomically: true, encoding: .utf8)

        try installer.install()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]
        let stopArray = hooks["Stop"] as! [[String: Any]]
        XCTAssertEqual(stopArray.count, 2)
    }

    func testInstallIsIdempotent() throws {
        try installer.install()
        try installer.install()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]
        let stopArray = hooks["Stop"] as! [[String: Any]]
        XCTAssertEqual(stopArray.count, 1)
    }

    func testInstallCreatesParentDirectoryIfMissing() throws {
        let nestedURL = tempDir
            .appendingPathComponent("subdir")
            .appendingPathComponent("settings.json")
        let nestedInstaller = ClaudeCodeInstaller(settingsURL: nestedURL)

        try nestedInstaller.install()

        XCTAssertTrue(FileManager.default.fileExists(atPath: nestedURL.path))
    }

    func testInstalledHooksAreAsync() throws {
        try installer.install()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]
        let stopArray = hooks["Stop"] as! [[String: Any]]
        let hookEntry = stopArray[0]
        let innerHooks = hookEntry["hooks"] as! [[String: Any]]
        XCTAssertEqual(innerHooks[0]["async"] as? Bool, true)
    }

    func testUninstallRemovesVisualpingHooks() throws {
        try installer.install()
        try installer.uninstall()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as? [String: Any] ?? [:]
        XCTAssertNil(hooks["Stop"])
        XCTAssertNil(hooks["Notification"])
        XCTAssertNil(hooks["PermissionRequest"])
    }

    func testUninstallPreservesOtherHooks() throws {
        let existing = """
        {"hooks":{"Stop":[{"matcher":"","hooks":[{"type":"command","command":"echo hi"}]},{"matcher":"","hooks":[{"type":"command","command":"visualping done","async":true}]}]}}
        """
        try existing.write(to: settingsURL, atomically: true, encoding: .utf8)

        try installer.uninstall()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]
        let stopArray = hooks["Stop"] as! [[String: Any]]
        XCTAssertEqual(stopArray.count, 1)
    }

    func testUninstallNoopsWhenNoFile() throws {
        XCTAssertNoThrow(try installer.uninstall())
    }

    func testInstalledHooksIncludeLabel() throws {
        try installer.install()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]

        for event in ["Stop", "Notification", "PermissionRequest"] {
            let eventArray = hooks[event] as! [[String: Any]]
            let innerHooks = eventArray[0]["hooks"] as! [[String: Any]]
            let command = innerHooks[0]["command"] as! String
            XCTAssertTrue(
                command.contains("--label"),
                "\(event) hook should include --label flag, got: \(command)"
            )
        }
    }

    func testUninstallNoopsWhenNoVisualpingHooks() throws {
        let existing = """
        {"hooks":{"Stop":[{"matcher":"","hooks":[{"type":"command","command":"echo hi"}]}]}}
        """
        try existing.write(to: settingsURL, atomically: true, encoding: .utf8)

        try installer.uninstall()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]
        let stopArray = hooks["Stop"] as! [[String: Any]]
        XCTAssertEqual(stopArray.count, 1)
    }
}
