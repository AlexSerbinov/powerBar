// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "PowerBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "PowerBar",
            targets: ["PowerBar"]
        )
    ],
    dependencies: [
        // No external dependencies required
    ],
    targets: [
        .executableTarget(
            name: "PowerBar",
            dependencies: [],
            path: "Sources/PowerBar"
        )
    ]
) 