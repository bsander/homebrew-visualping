// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "visualping",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "VisualpingCore"
        ),
        .executableTarget(
            name: "visualping",
            dependencies: [
                "VisualpingCore",
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "VisualpingTests",
            dependencies: ["VisualpingCore"]
        ),
    ]
)
