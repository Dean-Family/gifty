// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Gifty",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Gifty",
            targets: ["Gifty"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Gifty",
            dependencies: []),  // Add dependencies for this target if necessary
        .testTarget(
            name: "GiftyTests",
            dependencies: ["Gifty"]),
    ]
)
