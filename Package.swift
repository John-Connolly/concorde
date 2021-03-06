// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "concorde",
    products: [
        .library(name: "concorde", targets: ["concorde"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-html.git", from: "0.2.1"),
    ],
    targets: [
        .target(name: "Dev", dependencies: ["concorde", "Html",]),
        .target(name: "concorde", dependencies: ["NIO", "NIOHTTP1", "NIOWebSocket"]),
        .testTarget(name: "concordeTests", dependencies: ["concorde"]),
    ]
)
