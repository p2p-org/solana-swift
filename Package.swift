// swift-tools-version:5.8.0

import PackageDescription

let package = Package(
    name: "SolanaSwift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SolanaSwift",
            targets: ["SolanaSwift"]
        ),
        .library(
            name: "SolanaToken",
            targets: ["SolanaToken"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.0"),
        .package(url: "https://github.com/bitmark-inc/tweetnacl-swiftwrap.git", from: "1.0.2"),
        .package(url: "https://github.com/bigearsenal/task-retrying-swift.git", from: "2.0.0"),

        // Docs generator
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SolanaSwift",
            dependencies: [
                .product(name: "secp256k1", package: "secp256k1.swift"),
                .product(name: "TweetNacl", package: "tweetnacl-swiftwrap"),
                .product(name: "Task_retrying", package: "task-retrying-swift"),
            ]
        ),

        .testTarget(
            name: "SolanaSwiftUnitTests",
            dependencies: ["SolanaSwift"]
        ),

        .testTarget(
            name: "SolanaSwiftIntegrationTests",
            dependencies: ["SolanaSwift"]
        ),

        .target(
            name: "SolanaToken",
            dependencies: ["SolanaSwift"]
        ),

        .testTarget(
            name: "SolanaTokenTests",
            dependencies: ["SolanaToken"]
        ),
    ]
)
