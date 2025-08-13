// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "soto-elasticsearch",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SotoElasticsearch",
            targets: ["SotoElasticsearch"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/brokenhandsio/elasticsearch-nio-client.git", branch: "swift-6"),
        .package(url: "https://github.com/soto-project/soto.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "SotoElasticsearch",
            dependencies: [
                .product(name: "Elasticsearch", package: "elasticsearch-nio-client"),
                .product(name: "SotoElasticsearchService", package: "soto"),
            ]),
        .testTarget(
            name: "SotoElasticsearchTests",
            dependencies: ["SotoElasticsearch"]
        ),
    ]
)
