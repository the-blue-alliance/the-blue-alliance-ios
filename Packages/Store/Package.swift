// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Store",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "Store",
            targets: ["Store"]),
    ],
    dependencies: [
        .package(path: "../TBAData"),
        .package(path: "../TBAKit"),
    ],
    targets: [
        .target(
            name: "Store",
            dependencies: ["TBAData", "TBAKit"]),
        .testTarget(
            name: "StoreTests",
            dependencies: ["Store"]),
    ]
)
