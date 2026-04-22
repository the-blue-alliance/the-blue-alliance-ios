// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TBAUtils",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "TBAUtils",
            targets: ["TBAUtils"]
        )
    ],
    targets: [
        .target(name: "TBAUtils"),
        .testTarget(
            name: "TBAUtilsTests",
            dependencies: ["TBAUtils"]
        ),
    ]
)
