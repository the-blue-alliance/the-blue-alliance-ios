// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Search",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Search",
            targets: ["Search"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "TBAProtocols", path: "../TBAProtocols"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Search",
            dependencies: ["TBAProtocols"]),
        .testTarget(
            name: "SearchTests",
            dependencies: ["Search"]),
    ]
)
