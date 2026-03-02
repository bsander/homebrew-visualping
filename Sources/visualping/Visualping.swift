import AppKit
import ArgumentParser
import Lottie

enum ScreenPosition: String, CaseIterable, ExpressibleByArgument {
    case center
    case topLeft = "top-left"
    case topCenter = "top-center"
    case topRight = "top-right"
    case bottomLeft = "bottom-left"
    case bottomCenter = "bottom-center"
    case bottomRight = "bottom-right"
}

@main
struct Visualping: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Play Lottie animations as desktop overlays."
    )

    @Argument(help: "URL or local file path to a .json or .lottie animation.")
    var source: String

    @Option(name: .long, help: "Screen position: center, top-left, top-right, bottom-left, bottom-right.")
    var position: ScreenPosition = .center

    @Option(name: .long, help: "Animation width and height in pixels.")
    var size: Int = 300

    mutating func validate() throws {
        guard size > 0 else {
            throw ValidationError("--size must be a positive integer.")
        }
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
