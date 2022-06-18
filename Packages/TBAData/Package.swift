// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "TBAData",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TBAData",
            targets: ["TBAData"]),
        .library(
            name: "TBADataTesting",
            targets: ["TBADataTesting"]),
    ],
    dependencies: [
        .package(path: "../MyTBAKit"),
        .package(path: "../TBAKit"),
        .package(path: "../TBAProtocols"),
        .package(path: "../TBAUtils"),
    ],
    targets: [
        .target(
            name: "TBAData",
            dependencies: ["TBAKit", "MyTBAKit", "TBAProtocols", "TBAUtils"],
            resources: [
                .process("StatusDefaults.plist"),
                .process("TBA.xcdatamodeld"),
            ]),
        .target(
            name: "TBADataTesting",
            dependencies: ["TBAKit"]),
        .testTarget(
            name: "TBADataTests",
            dependencies: ["TBAData", "TBADataTesting"]),
    ]
)
