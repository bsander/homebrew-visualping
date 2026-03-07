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
    var animation: String

    @Option(name: .long, help: "Screen position: center, top-left, top-center, top-right, bottom-left, bottom-center, bottom-right.")
    var position: ScreenPosition?

    @Option(name: .long, help: "Animation size in pixels (e.g. 150) or percentage of screen height (e.g. 15%).")
    var size: String?

    @Option(name: .long, help: "Target screen: main, all, or a 1-based index (e.g. 2).")
    var screen: ScreenTarget?

    @Option(name: .long, help: "Animation duration in seconds.")
    var duration: Double?

    @Option(name: .long, help: "Text label displayed on a pill at the bottom of the animation.")
    var label: String?

    @Flag(name: .long, inversion: .prefixedNo, help: "Fill the entire screen.")
    var fullscreen: Bool?

    mutating func validate() throws {
        if let size { _ = try SizeParser.parse(size) }
        if let duration { try DurationValidator.validate(duration) }
    }

    mutating func run() throws {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        var loader = ConfigLoader()
        let config = loader.loadDefaults()
        let defaults = ResolvedDefaults(
            cliPosition: position,
            cliSize: size,
            cliScreen: screen,
            cliDuration: duration,
            cliFullscreen: fullscreen,
            config: config
        )

        let sizeSpec = try SizeParser.parse(defaults.size)
        if let duration = defaults.duration {
            try DurationValidator.validate(duration)
        }

        let resolvedLabel = LabelResolver.resolve(label: label)

        let delegate = AppDelegate(
            source: animation,
            position: defaults.position,
            sizeSpec: sizeSpec,
            screenTarget: defaults.screen,
            duration: defaults.duration,
            label: resolvedLabel,
            fullscreen: defaults.fullscreen
        )
        app.delegate = delegate
        app.run()
    }
}
