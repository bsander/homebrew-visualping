import CoreGraphics

public protocol AnimationPresenter {
    func present(filePath: String, position: ScreenPosition, size: CGFloat)
}
