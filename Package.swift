// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "CodeCopier", // Assuming this is the main package name
    platforms: [
        .macOS(.v14) // Or your specific macOS version
    ],
    dependencies: [
        // Other existing dependencies (if any) would go here
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/aespinilla/Tiktoken.git", .revision("main")), // Tiktoken for OpenAI token counting
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
        .target(
            name: "CodeCopierCore",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                // Dependencies for CodeCopierCore, e.g., Tiktoken if it's a separate package
                // If Tiktoken is vendored or part of Core, it's handled within its structure.
            ],
            path: "CodeCopier/Sources/CodeCopierCore"
        ),
        .target(
            name: "CodeCopierUI",
            dependencies: [
                "CodeCopierCore",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Tiktoken", package: "Tiktoken")
                // Other UI specific dependencies
            ],
            path: "CodeCopier/Sources/CodeCopierUI",
            resources: [.process("Assets.xcassets")]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["CodeCopierCore"],
            path: "CodeCopier/Tests/CoreTests"
        ),
        .testTarget(
            name: "CLITests",
            dependencies: ["CodeCopierCLI"],
            path: "CodeCopier/Tests/CLITests"
        ),
        // Add other targets as they exist in your project
    ]
) 