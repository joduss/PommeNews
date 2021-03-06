// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RssClient",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "RssClient",
            targets: ["RssClient"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/nmdias/FeedKit", from: "9.0.0"),
        .package(url: "https://github.com/alexaubry/HTMLString", from: "4.0.0"),
        .package(path: "../ZaJoLibrary")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "RssClient",
            dependencies: ["ZaJoLibrary", "FeedKit", "HTMLString"]),
        .testTarget(
            name: "RssClientTests",
            dependencies: ["ZaJoLibrary", "FeedKit", "HTMLString"]),
    ]
)
