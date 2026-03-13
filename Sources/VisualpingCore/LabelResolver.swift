import Foundation

public enum LabelResolver {
    public static func resolve(path: String?, pathStyle: PathStyle, label: String?) -> String? {
        let resolvedPath: String? = path.flatMap { p in
            let fullPath = (p == ".") ? FileManager.default.currentDirectoryPath : p
            switch pathStyle {
            case .short:
                return URL(fileURLWithPath: fullPath).lastPathComponent
            case .full:
                return fullPath
            }
        }

        let parts = [resolvedPath, label].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: ": ")
    }
}
