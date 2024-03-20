// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyTBAKit",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MyTBAKit",
            targets: ["MyTBAKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "TBAOperation", path: "../TBAOperation"),
        .package(name: "TBAUtils", path: "../TBAUtils"),
        .package(name: "TBATestingMocks", path: "../TBATestingMocks")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MyTBAKit",
            dependencies: ["TBAOperation", "TBAUtils"]),
        .testTarget(
            name: "MyTBAKitTests",
            dependencies: ["MyTBAKit", "TBATestingMocks"],
            resources: [
                .copy("data/")
            ]),
    ]
)
