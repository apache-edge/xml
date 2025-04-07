// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XML",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "XML",
            targets: ["XML"]),
        .executable(
            name: "XMLExample",
            targets: ["XMLExample"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "XML",
            dependencies: []),
        .executableTarget(
            name: "XMLExample",
            dependencies: ["XML"]),
        .testTarget(
            name: "XMLTests",
            dependencies: ["XML"]),
    ]
)