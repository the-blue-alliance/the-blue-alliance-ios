// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TBAAuth",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "TBAAuth",
            targets: ["TBAAuth"]
        )
    ],
    dependencies: [
        .package(path: "../TBAUtils"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.12.1"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "TBAAuth",
            dependencies: [
                "TBAUtils",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "TBAAuthTests",
            dependencies: ["TBAAuth"]
        ),
    ]
)
