public struct ValidationError: Error {
    public let message: String
    public init(_ message: String) {
        self.message = message
    }
}

public func validateSize(_ size: Int) throws {
    guard size > 0 else {
        throw ValidationError("--size must be a positive integer.")
    }
}
