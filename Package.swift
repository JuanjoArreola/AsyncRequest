// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "AsyncRequest",
    products: [
        .library(
            name: "AsyncRequest",
            targets: ["AsyncRequest"]),
        ],
    targets: [
        .target(
            name: "AsyncRequest",
            path: "Sources"
        ),
        .testTarget(
            name: "AsyncRequestTests",
            dependencies: ["AsyncRequest"],
            path: "Tests"
        )
    ]
)
