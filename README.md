# Soto Elasticsearch NIO Client

An AWS wrapper around [`ElasticsearchNIOClient`](https://github.com/brokenhandsio/elasticsearch-nio-client.git). This library allows you to send Elasticsearch queries and requests to the AWS Elasticsearch Service. It uses [Soto](https://github.com/soto-project/soto) to sign the requests. This library works with other Elasticsearch endpoints, including local ones as well as AWS.

## Installation and Usage

First add the library as a dependency in your dependencies array in **Package.swift**:

```swift
.package(url: "https://github.com/brokenhandsio/soto-elasticsearch-nio-client.git", from: "0.1.0"),
```

Then add the dependency to the target you require it in:

```swift
.target(
    name: "App",
    dependencies: [
        // ...
        .product(name: "SotoElasticsearchNIOClient", package: "soto-elasticsearch-nio-client")
    ],
)
```

Creating an instance of `SotoElasticsearchNIOClient` depends on your environment, but you should be able to work it out depending on what you need. For Vapor, for example, you'd do something like:

```swift
let elasticsearchClient = SotoElasticsearchClient(awsClient: req.application.aws.client, eventLoop: req.eventLoop, logger: req.logger, httpClient: req.application.http.client.shared, host: host)
```

## Supported Features

The library supports all the functionality of [`ElasticsearchNIOClient`](https://github.com/brokenhandsio/elasticsearch-nio-client.git). `SotoElasticsearchClient` exposes the underlying `ElasticsearchClient` you can pass requests to if needed, but most should be wrapped.

If you'd like to add extra functionality, either [open an issue](https://github.com/brokenhandsio/elasticsearch-nio-client/issues/new) and raise a PR. Any contributions are gratefully accepted!

## Elasticsearch Version

The library has been tested again Elasticsearch 7.6.2, but should work for the most part against older versions.
