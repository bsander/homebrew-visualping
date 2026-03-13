import Foundation

public struct LabelMetrics {
    private static let referenceHeight: CGFloat = 150
    private static let scaleRange: ClosedRange<CGFloat> = 0.5...3.0

    public let fontSize: CGFloat
    public let hPadding: CGFloat
    public let vPadding: CGFloat
    public let cornerRadius: CGFloat
    public let bottomMargin: CGFloat
    public let maxWidthInset: CGFloat

    public init(windowHeight: CGFloat) {
        let scale = min(max(windowHeight / Self.referenceHeight, Self.scaleRange.lowerBound), Self.scaleRange.upperBound)
        self.fontSize = 13 * scale
        self.hPadding = 10 * scale
        self.vPadding = 5 * scale
        self.cornerRadius = 12 * scale
        self.bottomMargin = 4 * scale
        self.maxWidthInset = 16 * scale
    }
}
