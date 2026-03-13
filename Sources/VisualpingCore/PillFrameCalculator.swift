import CoreGraphics

public enum PillFrame {
    public static let screenMargin: CGFloat = 8

    /// Calculate the frame for a pill window that is centered on the animation
    /// but clamped to stay within screen bounds.
    public static func calculate(
        animationFrame: CGRect,
        screenFrame: CGRect,
        pillSize: CGSize,
        bottomMargin: CGFloat
    ) -> CGRect {
        // Cap width to screen width minus margins
        let maxWidth = screenFrame.width - 2 * screenMargin
        let width = min(pillSize.width, maxWidth)

        // Start centered on animation
        var x = animationFrame.midX - width / 2

        // Clamp to screen bounds
        let minX = screenFrame.minX + screenMargin
        let maxX = screenFrame.maxX - screenMargin - width
        x = min(max(x, minX), maxX)

        // Position below the animation, clamped to screen bottom
        let y = max(
            animationFrame.minY - pillSize.height - bottomMargin,
            screenFrame.minY + screenMargin
        )

        return CGRect(x: x, y: y, width: width, height: pillSize.height)
    }
}
