import AppKit
import Lottie
import VisualpingCore

class AppDelegate: NSObject, NSApplicationDelegate {
    let source: String
    let position: ScreenPosition
    let size: CGFloat

    private var window: NSWindow?
    private var tempFileURL: URL?

    init(source: String, position: ScreenPosition, size: CGFloat) {
        self.source = source
        self.position = position
        self.size = size
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let url = tempFileURL {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        resolveSource { [weak self] filePath in
            guard let self else { return }
            DispatchQueue.main.async {
                self.showAnimation(from: filePath)
            }
        }
    }

    // MARK: - Source Resolution

    private func resolveSource(completion: @escaping (String) -> Void) {
        if source.hasPrefix("http://") || source.hasPrefix("https://") {
            downloadFile(from: source, completion: completion)
        } else {
            completion(source)
        }
    }

    private func downloadFile(from urlString: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: urlString) else {
            fputs("Error: Invalid URL '\(urlString)'\n", stderr)
            exit(1)
        }

        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let error {
                fputs("Error downloading: \(error.localizedDescription)\n", stderr)
                exit(1)
            }

            guard let tempURL else {
                fputs("Error: No data received from URL.\n", stderr)
                exit(1)
            }

            let ext = url.pathExtension.isEmpty ? "json" : url.pathExtension
            let dest = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(ext)

            do {
                try FileManager.default.moveItem(at: tempURL, to: dest)
                DispatchQueue.main.async { self.tempFileURL = dest }
                completion(dest.path)
            } catch {
                fputs("Error saving file: \(error.localizedDescription)\n", stderr)
                exit(1)
            }
        }
        task.resume()
    }

    // MARK: - Animation Display

    private func showAnimation(from filePath: String) {
        let animationView: LottieAnimationView

        if filePath.lowercased().hasSuffix(".lottie") {
            animationView = LottieAnimationView(
                dotLottieFilePath: filePath,
                configuration: .shared
            ) { [weak self] view, error in
                if let error {
                    fputs("Error loading .lottie: \(error.localizedDescription)\n", stderr)
                    exit(1)
                }
                DispatchQueue.main.async {
                    guard let self else {
                        NSApp.terminate(nil)
                        return
                    }
                    self.setupWindow(with: view)
                    self.playAnimation(view)
                }
            }
            return
        }

        animationView = LottieAnimationView(filePath: filePath)
        if animationView.animation == nil {
            fputs("Error: Could not load animation from '\(filePath)'\n", stderr)
            exit(1)
        }

        setupWindow(with: animationView)
        playAnimation(animationView)
    }

    private func setupWindow(with animationView: LottieAnimationView) {
        let frame = calculateWindowFrame()

        let window = NSWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]

        animationView.frame = NSRect(origin: .zero, size: frame.size)
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .forceFinish

        window.contentView = animationView
        window.orderFrontRegardless()

        self.window = window
    }

    private func playAnimation(_ animationView: LottieAnimationView) {
        animationView.loopMode = .playOnce
        animationView.play { _ in
            NSApp.terminate(nil)
        }
    }

    private func calculateWindowFrame() -> NSRect {
        guard let screen = NSScreen.main else {
            return NSRect(x: 0, y: 0, width: size, height: size)
        }
        return VisualpingCore.calculateWindowFrame(
            in: screen.visibleFrame,
            position: position,
            size: size
        )
    }
}
