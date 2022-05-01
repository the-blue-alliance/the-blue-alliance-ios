// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TBAKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TBAKit",
            targets: ["TBAKit"]),
        .library(
            name: "TBAKitTesting",
            targets: ["TBAKitTesting"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../TBAOperation"),
        .package(path: "../TBATestingMocks"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TBAKit",
            dependencies: ["TBAOperation"]),
        .target(
            name: "TBAKitTesting",
            dependencies: ["TBAKit", "TBATestingMocks"],
            resources: [
              .copy("Data"),
            ]),
        .testTarget(
            name: "TBAKitTests",
            dependencies: ["TBAKit", "TBAKitTesting"]),
    ]
)
