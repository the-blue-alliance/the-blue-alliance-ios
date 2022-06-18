// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TBAData2",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TBAData2",
            targets: ["TBAData2"]),
    ],
    dependencies: [
        .package(path: "../TBAKit"),
    ],
    targets: [
        .target(
            name: "TBAData2",
            dependencies: ["TBAKit"],
            resources: [
                .process("TBA.xcdatamodeld"),
            ]),
        .testTarget(
            name: "TBAData2Tests",
            dependencies: ["TBAData2"]),
    ]
)
