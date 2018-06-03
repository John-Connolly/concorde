// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "concord",
    products: [
        .library(name: "concord", targets: ["concord"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.8.0")
    ],
    targets: [
        .target(name: "Dev", dependencies: ["concord"]),
        .target(name: "concord", dependencies: ["NIO", "NIOHTTP1"]),
        .testTarget(name: "concordTests", dependencies: ["concord"]),
    ]
)
