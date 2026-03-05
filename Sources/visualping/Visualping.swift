import AppKit
import ArgumentParser
import Lottie
import VisualpingCore

extension ScreenPosition: ExpressibleByArgument {}

@main
struct Visualping: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Play Lottie animations as desktop overlays."
    )

    @Argument(help: "Keyword (e.g. done, error, attention), URL, or local file path.")
    var source: String

    @Option(name: .long, help: "Screen position: center, top-left, top-right, bottom-left, bottom-right.")
    var position: ScreenPosition = .center

    @Option(name: .long, help: "Animation width and height in pixels.")
    var size: Int = 300

    mutating func validate() throws {
        try VisualpingCore.validateSize(size)
    }

    mutating func run() throws {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let delegate = AppDelegate(
            source: source,
            position: position,
            size: CGFloat(size)
        )
        app.delegate = delegate
        app.run()
    }
}
