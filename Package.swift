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
        // Charts is a native Apple framework, no external dependency needed
    ],
    targets: [
        .executableTarget(
            name: "PowerBar",
            dependencies: [],
            path: "Sources/PowerBar"
        )
    ]
)
