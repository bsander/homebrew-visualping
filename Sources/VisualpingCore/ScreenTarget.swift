public enum ScreenTarget: Equatable {
    case main
    case all
    case index(Int)

    public static func parse(_ string: String) -> ScreenTarget? {
        switch string.lowercased() {
        case "main":
            return .main
        case "all":
            return .all
        default:
            guard let n = Int(string), n >= 1 else { return nil }
            return .index(n)
        }
    }
}
