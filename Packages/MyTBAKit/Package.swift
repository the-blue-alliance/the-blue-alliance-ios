// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "MyTBAKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "MyTBAKit",
            targets: ["MyTBAKit"]),
        .library(
            name: "MyTBAKitTesting",
            targets: ["MyTBAKitTesting"]),
    ],
    dependencies: [
        .package(path: "../TBAOperation"),
        .package(path: "../TBATestingMocks"),
        .package(path: "../TBAUtils"),
    ],
    targets: [
        .target(
            name: "MyTBAKit",
            dependencies: ["TBAOperation", "TBAUtils"]),
        .target(
            name: "MyTBAKitTesting",
            dependencies: ["MyTBAKit", "TBATestingMocks"],
            resources: [
                .copy("Data")
            ]),
        .testTarget(
            name: "MyTBAKitTests",
            dependencies: ["MyTBAKit", "MyTBAKitTesting"]),
    ]
)
