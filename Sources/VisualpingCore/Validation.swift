public struct ValidationError: Error {
    public let message: String
    public init(_ message: String) {
        self.message = message
    }
}

public enum SizeSpec {
    case pixels(Int)
    case percent(Double)
}

public func parseSize(_ value: String) throws -> SizeSpec {
    if value.hasSuffix("%") {
        let numStr = String(value.dropLast())
        guard let pct = Double(numStr), pct > 0 else {
            throw ValidationError("--size percentage must be a positive number (e.g. 10%).")
        }
        return .percent(pct)
    }
    guard let px = Int(value), px > 0 else {
        throw ValidationError("--size must be a positive integer or a percentage (e.g. 150, 10%).")
    }
    return .pixels(px)
}

public func validateDuration(_ duration: Double) throws {
    guard duration > 0 else {
        throw ValidationError("--duration must be a positive number.")
    }
}
