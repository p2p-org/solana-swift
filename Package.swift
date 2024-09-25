// swift-tools-version:5.7.1

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
        .library(
            name: "SolanaSwift",
            targets: ["SolanaSwift"]
        ),
    ],
    dependencies: [
        // Main depedencies
        .package(url: "https://github.com/shamatar/secp256k1_ios.git", from: "0.1.3"),
        .package(url: "https://github.com/bitmark-inc/tweetnacl-swiftwrap.git", from: "1.0.2"),
        .package(url: "https://github.com/bigearsenal/task-retrying-swift.git", from: "2.0.0"),

        // Docs generator
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SolanaSwift",
            dependencies: [
                .product(name: "secp256k1", package: "secp256k1_ios"),
                .product(name: "TweetNacl", package: "tweetnacl-swiftwrap"),
                .product(name: "Task_retrying", package: "task-retrying-swift"),
            ]
        ),
        .testTarget(
            name: "SolanaSwiftUnitTests",
            dependencies: ["SolanaSwift"],
            resources: [
                .process("Resources/get_all_tokens_info.json"),
            ]
        ),
        .testTarget(
            name: "SolanaSwiftIntegrationTests",
            dependencies: ["SolanaSwift"]
        ),
    ]
)
