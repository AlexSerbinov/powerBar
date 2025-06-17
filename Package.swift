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
        .package(url: "https://github.com/apple/swift-charts", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "PowerBar",
            dependencies: [
                .product(name: "Charts", package: "swift-charts")
            ],
            path: "Sources/PowerBar"
        )
    ]
)
