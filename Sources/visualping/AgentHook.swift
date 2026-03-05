import ArgumentParser
import VisualpingCore

extension AgentTool: ExpressibleByArgument {}

struct AgentHook: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "agent-hook",
        abstract: "Install or remove visualping hooks for AI coding tools."
    )

    @Argument(help: "Agent tool to configure: claude, opencode.")
    var tool: AgentTool

    @Flag(name: .long, help: "Remove previously installed hooks.")
    var uninstall = false

    mutating func run() throws {
        switch tool {
        case .claude:
            let installer = ClaudeCodeInstaller()
            if uninstall {
                try installer.uninstall()
                print("Removed visualping hooks from Claude Code.")
            } else {
                try installer.install()
                print("Installed visualping hooks for Claude Code.")
            }
        case .opencode:
            let installer = OpenCodeInstaller()
            if uninstall {
                try installer.uninstall()
                print("Removed visualping plugin from opencode.")
            } else {
                try installer.install()
                print("Installed visualping plugin for opencode.")
            }
        }
    }
}
