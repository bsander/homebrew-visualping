import CoreGraphics

public let defaultMargin: CGFloat = 16

public func calculateWindowFrame(
    in screenFrame: CGRect,
    position: ScreenPosition,
    size: CGFloat,
    margin: CGFloat = defaultMargin
) -> CGRect {
    let x: CGFloat
    let y: CGFloat

    switch position {
    case .center:
        x = screenFrame.midX - size / 2
        y = screenFrame.midY - size / 2
    case .topLeft:
        x = screenFrame.minX + margin
        y = screenFrame.maxY - size - margin
    case .topCenter:
        x = screenFrame.midX - size / 2
        y = screenFrame.maxY - size - margin
    case .topRight:
        x = screenFrame.maxX - size - margin
        y = screenFrame.maxY - size - margin
    case .bottomLeft:
        x = screenFrame.minX + margin
        y = screenFrame.minY + margin
    case .bottomCenter:
        x = screenFrame.midX - size / 2
        y = screenFrame.minY + margin
    case .bottomRight:
        x = screenFrame.maxX - size - margin
        y = screenFrame.minY + margin
    }

    return CGRect(x: x, y: y, width: size, height: size)
}

public func calculateFullscreenFrame(in screenFrame: CGRect) -> CGRect {
    return screenFrame
}
