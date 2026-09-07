// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MyTBAKit",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "MyTBAKit",
            targets: ["MyTBAKit"]
        )
    ],
    targets: [
        .target(name: "MyTBAKit"),
        .testTarget(
            name: "MyTBAKitTests",
            dependencies: ["MyTBAKit"],
            resources: [
                .copy("data/")
            ]
        ),
    ]
)
