import AppKit
import Lottie
import VisualpingCore

struct URLSessionDownloader: URLDownloader {
    func download(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let tempURL else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            let ext = url.pathExtension.isEmpty ? "json" : url.pathExtension
            let dest = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(ext)
            do {
                try FileManager.default.moveItem(at: tempURL, to: dest)
                completion(.success(dest))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let source: String
    let position: ScreenPosition
    let size: CGFloat

    private var window: NSWindow?
    private var tempFileURL: URL?
    private let sourceResolver: SourceResolver
    private let keywordResolver = KeywordResolver()

    init(source: String, position: ScreenPosition, size: CGFloat) {
        self.source = source
        self.position = position
        self.size = size
        self.sourceResolver = SourceResolver(downloader: URLSessionDownloader())
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let url = tempFileURL {
            try? FileManager.default.removeItem(at: url)
        }
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
                DispatchQueue.main.async {
                    self.showAnimation(from: cachedPath)
                }
            } else {
                resolveAndCacheSource(resolvedSource, cache: cache)
            }
        } else if resolvedSource != source {
            // Keyword resolved to a local file path
            DispatchQueue.main.async {
                self.showAnimation(from: resolvedSource)
            }
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
        sourceResolver.resolve(source) { [weak self] result in
            switch result {
            case .success(let path):
                if self?.source.hasPrefix("https") == true {
                    self?.tempFileURL = URL(fileURLWithPath: path)
                }
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
