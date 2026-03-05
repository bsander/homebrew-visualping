import AppKit
import ArgumentParser
import Lottie
import VisualpingCore

extension ScreenPosition: ExpressibleByArgument {}

extension ScreenTarget: ExpressibleByArgument {
    public init?(argument: String) {
        guard let target = ScreenTarget.parse(argument) else { return nil }
        self = target
    }
}

@main
struct Visualping: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Play Lottie animations as desktop overlays.",
        subcommands: [Play.self, AgentHook.self],
        defaultSubcommand: Play.self
    )
}

struct Play: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Play a Lottie animation overlay."
    )

    @Argument(help: "Keyword (e.g. done, error, attention), URL, or local file path.")
    var source: String

    @Option(name: .long, help: "Screen position: center, top-left, top-right, bottom-left, bottom-right.")
    var position: ScreenPosition = .center

    @Option(name: .long, help: "Animation width and height in pixels.")
    var size: Int = 300

    @Option(name: .long, help: "Target screen: main, all, or a 1-based index (e.g. 2).")
    var screen: ScreenTarget = .main

    @Option(name: .long, help: "Text label displayed on a glass pill at the bottom of the animation.")
    var label: String?

    mutating func validate() throws {
        try VisualpingCore.validateSize(size)
    }

    mutating func run() throws {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let delegate = AppDelegate(
            source: source,
            position: position,
            size: CGFloat(size),
            screenTarget: screen,
            label: label
        )
        app.delegate = delegate
        app.run()
    }
}
