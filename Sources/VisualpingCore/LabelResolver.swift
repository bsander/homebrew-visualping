import Foundation

public enum LabelResolver {
    public static func resolve(path: String?, label: String?) -> String? {
        let pathComponent: String? = path.map {
            URL(fileURLWithPath: $0).lastPathComponent
        }

        switch (pathComponent, label) {
        case let (p?, l?):
            return "\(p): \(l)"
        case let (p?, nil):
            return p
        case let (nil, l?):
            return l
        case (nil, nil):
            return nil
        }
    }
}
