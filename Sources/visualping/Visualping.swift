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
    var position: ScreenPosition = .bottomCenter

    @Option(name: .long, help: "Animation size in pixels (e.g. 150) or percentage of screen height (e.g. 15%).")
    var size: String = "10%"

    @Option(name: .long, help: "Target screen: main, all, or a 1-based index (e.g. 2).")
    var screen: ScreenTarget = .main

    @Option(name: .long, help: "Animation duration in seconds.")
    var duration: Double = 1.5

    @Option(name: .long, help: "Text label displayed on a pill at the bottom of the animation.")
    var label: String?

    @Option(name: .long, help: "Path whose last component is displayed as the label.")
    var path: String?

    mutating func validate() throws {
        _ = try VisualpingCore.parseSize(size)
        try VisualpingCore.validateDuration(duration)
    }

    mutating func run() throws {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let resolvedLabel = LabelResolver.resolve(path: path, label: label)

        let delegate = AppDelegate(
            source: source,
            position: position,
            sizeSpec: try! VisualpingCore.parseSize(size),
            screenTarget: screen,
            duration: duration,
            label: resolvedLabel
        )
        app.delegate = delegate
        app.run()
    }
}
