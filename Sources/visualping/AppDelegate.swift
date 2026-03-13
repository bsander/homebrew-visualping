import AppKit
import Lottie
import VisualpingCore

class AppDelegate: NSObject, NSApplicationDelegate {
    let source: String
    let position: ScreenPosition
    let sizeSpec: SizeSpec
    let screenTarget: ScreenTarget
    let duration: Double?
    let label: String?
    let fullscreen: Bool

    private var windows: [NSWindow] = []
    private var completionCount = 0
    private var totalAnimations = 0
    private let sourceResolver: SourceResolver
    private var keywordResolver = KeywordResolver()

    init(source: String, position: ScreenPosition, sizeSpec: SizeSpec, screenTarget: ScreenTarget = .main, duration: Double? = nil, label: String? = nil, fullscreen: Bool = false) {
        self.source = source
        self.position = position
        self.sizeSpec = sizeSpec
        self.screenTarget = screenTarget
        self.duration = duration
        self.label = label
        self.fullscreen = fullscreen
        self.sourceResolver = SourceResolver(downloader: URLSessionDownloader())
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let resolvedSource: String
        if let keywordPath = keywordResolver.resolve(source) {
            resolvedSource = keywordPath
        } else {
            resolvedSource = source
        }

        // If keyword resolved to a URL, use SourceResolver for download+cache
        if resolvedSource.hasPrefix("http://") || resolvedSource.hasPrefix("https://") {
            let cache = AnimationCache()
            if cache.isCached(urlString: resolvedSource) {
                let cachedPath = cache.cachedPath(for: resolvedSource)
                showAnimation(from: cachedPath)
            } else {
                resolveAndCacheSource(resolvedSource, cache: cache)
            }
        } else if resolvedSource != source {
            showAnimation(from: resolvedSource)
        } else {
            // Not a keyword — use existing resolution flow
            resolveSource { [weak self] filePath in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.showAnimation(from: filePath)
                }
            }
        }
    }

    // MARK: - Source Resolution

    private func resolveSource(completion: @escaping (String) -> Void) {
        sourceResolver.resolve(source) { result in
            switch result {
            case .success(let path):
                completion(path)
            case .failure(let error):
                fputs("Error: \(error)\n", stderr)
                exit(1)
            }
        }
    }

    private func resolveAndCacheSource(_ urlString: String, cache: AnimationCache) {
        sourceResolver.resolve(urlString) { [weak self] result in
            switch result {
            case .success(let downloadedPath):
                try? cache.store(fileAt: downloadedPath, for: urlString)
                try? FileManager.default.removeItem(atPath: downloadedPath)
                let cachedPath = cache.cachedPath(for: urlString)
                DispatchQueue.main.async {
                    self?.showAnimation(from: cachedPath)
                }
            case .failure(let error):
                fputs("Error: \(error)\n", stderr)
                exit(1)
            }
        }
    }

    // MARK: - Animation Display

    private func showAnimation(from filePath: String) {
        let screens = resolveScreens()
        for screen in screens {
            showAnimationOnScreen(from: filePath, screen: screen)
        }
    }

    private func resolveScreens() -> [NSScreen] {
        switch screenTarget {
        case .main:
            guard let main = NSScreen.main else { return [] }
            return [main]
        case .all:
            return NSScreen.screens
        case .index(let n):
            let allScreens = NSScreen.screens
            guard n >= 1, n <= allScreens.count else {
                fputs("Error: screen \(n) not found (\(allScreens.count) screen\(allScreens.count == 1 ? "" : "s") available)\n", stderr)
                exit(1)
            }
            return [allScreens[n - 1]]
        }
    }

    private func showAnimationOnScreen(from filePath: String, screen: NSScreen) {
        let animationView: LottieAnimationView

        if AnimationFormat.detect(from: filePath) == .dotLottie {
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
                    self.setupWindow(with: view, on: screen)
                    self.playAnimation(view)
                }
            }
            totalAnimations += 1
            return
        }

        animationView = LottieAnimationView(filePath: filePath)
        if animationView.animation == nil {
            fputs("Error: Could not load animation from '\(filePath)'\n", stderr)
            exit(1)
        }

        totalAnimations += 1
        setupWindow(with: animationView, on: screen)
        playAnimation(animationView)
    }

    private func resolveSize(for screen: NSScreen) -> CGFloat {
        switch sizeSpec {
        case .pixels(let px):
            return CGFloat(px)
        case .percent(let pct):
            return screen.visibleFrame.height * CGFloat(pct) / 100
        }
    }

    private func setupWindow(with animationView: LottieAnimationView, on screen: NSScreen) {
        let frame: CGRect
        if fullscreen {
            frame = screen.frame
        } else {
            let size = resolveSize(for: screen)
            frame = WindowFrame.calculate(
                in: screen.visibleFrame,
                position: position,
                size: size
            )
        }

        let window = NSWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = fullscreen ? .screenSaver : .floating
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]

        animationView.frame = NSRect(origin: .zero, size: frame.size)
        animationView.contentMode = fullscreen ? .scaleAspectFill : .scaleAspectFit
        animationView.backgroundBehavior = .forceFinish

        window.contentView = animationView
        window.orderFrontRegardless()

        addLabelOverlay(to: window, on: screen)

        windows.append(window)
    }

    private func addLabelOverlay(to animationWindow: NSWindow, on screen: NSScreen) {
        guard let label, !label.isEmpty else { return }

        let metrics = LabelMetrics(windowHeight: animationWindow.frame.height)

        let textField = NSTextField(labelWithString: label)
        textField.font = NSFont.systemFont(ofSize: metrics.fontSize, weight: .semibold)
        textField.textColor = .white
        textField.alignment = .center
        textField.lineBreakMode = .byWordWrapping
        textField.maximumNumberOfLines = 0
        textField.translatesAutoresizingMaskIntoConstraints = false

        let pill = NSView()
        pill.wantsLayer = true
        pill.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.6).cgColor
        pill.layer?.cornerRadius = metrics.cornerRadius
        pill.layer?.masksToBounds = true
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: metrics.hPadding),
            textField.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -metrics.hPadding),
            textField.topAnchor.constraint(equalTo: pill.topAnchor, constant: metrics.vPadding),
            textField.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -metrics.vPadding),
        ])

        // Calculate the max pill width available on screen
        let maxPillWidth = screen.visibleFrame.width - 2 * PillFrame.screenMargin
        // Constrain text width so it wraps at a reasonable length
        let textMaxWidth = min(maxPillWidth - 2 * metrics.hPadding, 400 * metrics.fontSize / 16)
        textField.preferredMaxLayoutWidth = textMaxWidth

        // Use the text field's own fittingSize (accounts for center-alignment
        // internal padding that intrinsicContentSize under-reports)
        let textFitting = textField.fittingSize
        let pillSize = CGSize(
            width: ceil(textFitting.width + 2 * metrics.hPadding),
            height: ceil(textFitting.height + 2 * metrics.vPadding)
        )
        pill.setFrameSize(pillSize)

        // Create a separate window for the pill
        let pillFrame = PillFrame.calculate(
            animationFrame: animationWindow.frame,
            screenFrame: screen.visibleFrame,
            pillSize: pillSize,
            bottomMargin: metrics.bottomMargin
        )

        let pillWindow = NSWindow(
            contentRect: pillFrame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        pillWindow.isOpaque = false
        pillWindow.backgroundColor = .clear
        pillWindow.hasShadow = false
        pillWindow.level = animationWindow.level
        pillWindow.ignoresMouseEvents = true
        pillWindow.collectionBehavior = [.canJoinAllSpaces, .stationary]

        pill.frame = NSRect(origin: .zero, size: pillFrame.size)
        textField.translatesAutoresizingMaskIntoConstraints = true
        textField.frame = NSRect(
            x: metrics.hPadding,
            y: metrics.vPadding,
            width: textFitting.width,
            height: textFitting.height
        )

        pillWindow.contentView = pill
        pillWindow.orderFrontRegardless()

        windows.append(pillWindow)
    }

    private func playAnimation(_ animationView: LottieAnimationView) {
        animationView.loopMode = .playOnce
        if let duration, let nativeDuration = animationView.animation?.duration, nativeDuration > 0 {
            animationView.animationSpeed = CGFloat(nativeDuration / duration)
        }
        animationView.play { [weak self] _ in
            guard let self else { return }
            self.completionCount += 1
            if self.completionCount >= self.totalAnimations {
                NSApp.terminate(nil)
            }
        }
    }
}
