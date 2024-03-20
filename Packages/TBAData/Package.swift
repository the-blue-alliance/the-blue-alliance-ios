// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TBAData",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TBAData",
            targets: ["TBAData"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "MyTBAKit", path: "../MyTBAKit"),
        .package(name: "Search", path: "../Search"),
        .package(name: "TBAKit", path: "../TBAKit"),
        .package(name: "TBAUtils", path: "../TBAUtils"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TBAData",
            dependencies: ["MyTBAKit", "Search", "TBAKit", "TBAUtils"],
            resources: [
                .copy("Resources/TBA.xcdatamodeld"),
                .copy("Resources/StatusDefaults.plist"),
            ]),
        .testTarget(
            name: "TBADataTests",
            dependencies: ["TBAData"]),
    ]
)
