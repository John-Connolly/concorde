// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "concorde",
    products: [
        .library(name: "concorde", targets: ["concorde"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.8.0")
    ],
    targets: [
        .target(name: "Dev", dependencies: ["concorde"]),
        .target(name: "concorde", dependencies: ["NIO", "NIOHTTP1"]),
        .testTarget(name: "concordeTests", dependencies: ["concorde"]),
    ]
)
