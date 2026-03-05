import XCTest
@testable import VisualpingCore

final class OpenCodeInstallerTests: XCTestCase {
    var tempDir: URL!
    var pluginURL: URL!
    var installer: OpenCodeInstaller!

    override func setUp() {
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        pluginURL = tempDir
            .appendingPathComponent(".opencode/plugins/visualping.js")
        installer = OpenCodeInstaller(pluginURL: pluginURL)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testInstallCreatesPluginFile() throws {
        try installer.install()
        XCTAssertTrue(FileManager.default.fileExists(atPath: pluginURL.path))
    }

    func testInstallContentContainsSessionIdle() throws {
        try installer.install()
        let content = try String(contentsOf: pluginURL, encoding: .utf8)
        XCTAssertTrue(content.contains("session.idle"))
    }

    func testInstallContentContainsPermissionAsked() throws {
        try installer.install()
        let content = try String(contentsOf: pluginURL, encoding: .utf8)
        XCTAssertTrue(content.contains("permission.asked"))
    }

    func testInstallContentContainsVisualpingDone() throws {
        try installer.install()
        let content = try String(contentsOf: pluginURL, encoding: .utf8)
        XCTAssertTrue(content.contains("visualping done"))
    }

    func testInstallIsIdempotent() throws {
        try installer.install()
        let content1 = try String(contentsOf: pluginURL, encoding: .utf8)
        try installer.install()
        let content2 = try String(contentsOf: pluginURL, encoding: .utf8)
        XCTAssertEqual(content1, content2)
    }

    func testInstallCreatesDirectories() throws {
        let nestedURL = tempDir
            .appendingPathComponent("deep/nested/visualping.js")
        let nestedInstaller = OpenCodeInstaller(pluginURL: nestedURL)

        try nestedInstaller.install()

        XCTAssertTrue(FileManager.default.fileExists(atPath: nestedURL.path))
    }

    func testUninstallRemovesPluginFile() throws {
        try installer.install()
        try installer.uninstall()
        XCTAssertFalse(FileManager.default.fileExists(atPath: pluginURL.path))
    }

    func testUninstallNoopsWhenNoFile() throws {
        XCTAssertNoThrow(try installer.uninstall())
    }
}
