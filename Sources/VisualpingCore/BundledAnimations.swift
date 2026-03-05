import Foundation

public enum BundledAnimations {
    public static let availableKeywords = ["done", "error", "attention"]

    public static func path(for keyword: String) -> String? {
        guard availableKeywords.contains(keyword) else { return nil }
        return Bundle.module.path(forResource: keyword, ofType: "json")
    }
}
