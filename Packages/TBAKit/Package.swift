// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TBAKit",
    platforms: [
        .macOS("12.0"), // TODO: Drop, when we can
        .iOS("15.0") // TODO: Change to .v15 when available
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TBAKit",
            targets: ["TBAKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TBAKit",
            dependencies: []),
        .testTarget(
            name: "TBAKitTests",
            dependencies: ["TBAKit"],
            resources: [
              .copy("Data"),
            ]),
    ]
)