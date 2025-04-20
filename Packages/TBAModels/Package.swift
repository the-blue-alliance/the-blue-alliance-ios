// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TBAModels",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "TBAModels",
            targets: ["TBAModels"]),
    ],
    dependencies: [
        .package(path: "../TBAAPI"),
        .package(path: "../TBAUtils"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "TBAModels",
            dependencies: [
                .product(name: "TBAAPI", package: "TBAAPI"),
                .product(name: "TBAUtils", package: "TBAUtils"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        ),
        .testTarget(
            name: "TBAModelsTests",
            dependencies: ["TBAModels"]
        ),
    ]
)
