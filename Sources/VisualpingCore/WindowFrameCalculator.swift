import CoreGraphics

public func calculateWindowFrame(
    in screenFrame: CGRect,
    position: ScreenPosition,
    size: CGFloat
) -> CGRect {
    let x: CGFloat
    let y: CGFloat

    switch position {
    case .center:
        x = screenFrame.midX - size / 2
        y = screenFrame.midY - size / 2
    case .topLeft:
        x = screenFrame.minX
        y = screenFrame.maxY - size
    case .topCenter:
        x = screenFrame.midX - size / 2
        y = screenFrame.maxY - size
    case .topRight:
        x = screenFrame.maxX - size
        y = screenFrame.maxY - size
    case .bottomLeft:
        x = screenFrame.minX
        y = screenFrame.minY
    case .bottomCenter:
        x = screenFrame.midX - size / 2
        y = screenFrame.minY
    case .bottomRight:
        x = screenFrame.maxX - size
        y = screenFrame.minY
    }

    return CGRect(x: x, y: y, width: size, height: size)
}
