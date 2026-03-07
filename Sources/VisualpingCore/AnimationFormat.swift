public enum AnimationFormat: Equatable {
    case json
    case dotLottie

    public static func detect(from filePath: String) -> AnimationFormat {
        filePath.lowercased().hasSuffix(".lottie") ? .dotLottie : .json
    }
}
