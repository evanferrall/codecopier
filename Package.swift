// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "CodeCopier", // Assuming this is the main package name
    platforms: [
        .macOS(.v14) // Or your specific macOS version
    ],
    dependencies: [
        // .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"), // REMOVED
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/aespinilla/Tiktoken.git", branch: "main"), // Use branch: "main"
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0"), // Logging API
        // Assuming Tiktoken and other dependencies are declared elsewhere or part of CodeCopierCore
        // For example, if CodeCopierCore is a local package:
        // .package(path: "CodeCopier/Sources/CodeCopierCore")
    ],
    targets: [
        .executableTarget( // Assuming CodeCopierCLI is your command-line executable
            name: "CodeCopierCLI",
            dependencies: [
                "CodeCopierCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "CodeCopier/Sources/CodeCopierCLI"
        ),
        .executableTarget(
            name: "CodeCopierUI",
            dependencies: [
                "CodeCopierCore",
                .product(name: "Collections", package: "swift-collections"),
                // .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"), // REMOVED
                "Tiktoken"
            ],
            path: "CodeCopier/Sources/CodeCopierUI",
            resources: [.process("Assets.xcassets")],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .target(
            name: "CodeCopierCore",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Logging", package: "swift-log"),
                "Tiktoken"
            ],
            path: "CodeCopier/Sources/CodeCopierCore"
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["CodeCopierCore"],
            path: "CodeCopier/Tests/CoreTests",
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "CLITests",
            dependencies: ["CodeCopierCLI"],
            path: "CodeCopier/Tests/CLITests",
            resources: [.copy("Fixtures")] // Added fixture resources for CLI tests
        ),
        .testTarget(
            name: "UITests",
            dependencies: ["CodeCopierUI"],
            path: "CodeCopier/Tests/UITests"
        ),
        // Add other targets as they exist in your project
        .plugin(
            name: "ReleaseDmgPlugin",
            capability: .buildTool, // Assuming .buildTool; adjust if it's a .command plugin
            path: "CodeCopier/Sources/Plugins/ReleaseDmgPlugin"
        )
    ]
) 