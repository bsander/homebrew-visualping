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
        XCTAssertNil(hooks["PermissionRequest"])
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

    func testInstalledHooksAreSync() throws {
        try installer.install()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]
        let stopArray = hooks["Stop"] as! [[String: Any]]
        let hookEntry = stopArray[0]
        let innerHooks = hookEntry["hooks"] as! [[String: Any]]
        XCTAssertEqual(innerHooks[0]["async"] as? Bool, false)
    }

    func testUninstallRemovesVisualpingHooks() throws {
        try installer.install()
        try installer.uninstall()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as? [String: Any] ?? [:]
        XCTAssertNil(hooks["Stop"])
        XCTAssertNil(hooks["Notification"])
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

    func testInstalledHooksDoNotShellExpandEnvVars() throws {
        try installer.install()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]

        for event in ["Stop", "Notification"] {
            let eventArray = hooks[event] as! [[String: Any]]
            let innerHooks = eventArray[0]["hooks"] as! [[String: Any]]
            let command = innerHooks[0]["command"] as! String
            XCTAssertFalse(
                command.contains("$"),
                "\(event) hook should not shell-expand env vars, got: \(command)"
            )
        }
    }

    func testInstalledHooksAreSimpleCommands() throws {
        try installer.install()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]

        let stopArray = hooks["Stop"] as! [[String: Any]]
        let stopHooks = stopArray[0]["hooks"] as! [[String: Any]]
        XCTAssertEqual(stopHooks[0]["command"] as? String, "visualping done")

        let notifArray = hooks["Notification"] as! [[String: Any]]
        let notifHooks = notifArray[0]["hooks"] as! [[String: Any]]
        XCTAssertEqual(notifHooks[0]["command"] as? String, "visualping attention")
    }

    func testInstallUpdatesExistingVisualpingHooks() throws {
        let oldHooks = """
        {"hooks":{"Stop":[{"matcher":"","hooks":[{"type":"command","command":"visualping done --label old","async":false}]}]}}
        """
        try oldHooks.write(to: settingsURL, atomically: true, encoding: .utf8)

        try installer.install()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]
        let stopArray = hooks["Stop"] as! [[String: Any]]
        XCTAssertEqual(stopArray.count, 1, "Should replace, not duplicate")
        let innerHooks = stopArray[0]["hooks"] as! [[String: Any]]
        let command = innerHooks[0]["command"] as! String
        XCTAssertEqual(command, "visualping done", "Should update to latest command format")
    }

    func testInstalledHooksOmitPositionAndScreen() throws {
        try installer.install()

        let data = try Data(contentsOf: settingsURL)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hooks = json["hooks"] as! [String: Any]

        for event in ["Stop", "Notification"] {
            let eventArray = hooks[event] as! [[String: Any]]
            let innerHooks = eventArray[0]["hooks"] as! [[String: Any]]
            let command = innerHooks[0]["command"] as! String
            XCTAssertFalse(
                command.contains("--position"),
                "\(event) hook should not include --position, got: \(command)"
            )
            XCTAssertFalse(
                command.contains("--screen"),
                "\(event) hook should not include --screen, got: \(command)"
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
