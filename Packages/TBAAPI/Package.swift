// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Downgraded from 6.1 so the package resolves under the Xcode 16.2 pin that
// the release branch's CI uses to dodge the Swift 6.1+ async-let codegen bug.
// Nothing in this manifest actually requires 6.1. Safe to bump back once the
// Xcode pin is removed.

import PackageDescription

let package = Package(
    name: "TBAAPI",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "TBAAPI",
            targets: ["TBAAPI"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "TBAAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),
        .executableTarget(
            name: "TBAAPI-main",
            dependencies: ["TBAAPI"]
        ),
        .testTarget(
            name: "TBAAPITests",
            dependencies: ["TBAAPI"]
        )
    ]
)
