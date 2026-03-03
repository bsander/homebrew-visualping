import Foundation

public enum AnimationFormat: Equatable {
    case json
    case dotLottie

    public static func detect(from filePath: String) -> AnimationFormat {
        filePath.lowercased().hasSuffix(".lottie") ? .dotLottie : .json
    }
}

public protocol AnimationLoader {
    func load(from path: String, format: AnimationFormat, completion: @escaping (Result<Void, Error>) -> Void)
}

public struct AnimationRouter {
    public let loader: AnimationLoader

    public init(loader: AnimationLoader) {
        self.loader = loader
    }

    public func route(filePath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let format = AnimationFormat.detect(from: filePath)
        loader.load(from: filePath, format: format, completion: completion)
    }
}
