// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "TBAData",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
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
        .package(path: "../TBAKit"),
        .package(path: "../TBAUtils"),
    ],
    targets: [
        .target(
            name: "TBAData",
            dependencies: ["TBAKit", "TBAUtils"],
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
