// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "soto-elasticsearch-nio-client",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "SotoElasticsearchNIOClient", targets: ["SotoElasticsearchNIOClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
        .package(url: "https://github.com/brokenhandsio/elasticsearch-nio-client.git", from: "0.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SotoElasticsearchNIOClient", dependencies: [
                .product(name: "ElasticsearchNIOClient", package: "elasticsearch-nio-client"),
                .product(name: "SotoElasticsearchService", package: "soto"),
        ]),
        .testTarget(
            name: "SotoElasticsearchNIOClientTests",
            dependencies: ["SotoElasticsearchNIOClient"]),
    ]
)
