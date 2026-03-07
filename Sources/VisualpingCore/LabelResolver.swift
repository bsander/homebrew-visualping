import Foundation

public enum LabelResolver {
    public static func resolve(label: String?) -> String? {
        let project = detectProjectName()

        switch (project, label) {
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

    private static func detectProjectName() -> String? {
        let cwd = FileManager.default.currentDirectoryPath
        let name = URL(fileURLWithPath: cwd).lastPathComponent
        return name.isEmpty ? nil : name
    }
}
