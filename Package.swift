// swift-tools-version:5.4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SolanaSwift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v10),
        .watchOS(.v3),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SolanaSwift",
            targets: ["SolanaSwift"]
        ),
    ],
    dependencies: [
        .package(name: "secp256k1", url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.0"),
        .package(name: "TweetNacl", url: "https://github.com/bitmark-inc/tweetnacl-swiftwrap.git", from: "1.0.2"),

        .package(name: "Task_retrying", url: "https://github.com/bigearsenal/task-retrying-swift.git", from: "1.0.3"),

        // Docs generator
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SolanaSwift",
            dependencies: [
                "secp256k1",
                "TweetNacl",
                "Task_retrying"
            ]
//            resources: [ .process("Resources") ]
        ),
        .testTarget(
            name: "SolanaSwiftUnitTests",
            dependencies: ["SolanaSwift"]
//            resources: [ .process("Resources") ]
        ),
        .testTarget(
            name: "SolanaSwiftIntegrationTests",
            dependencies: ["SolanaSwift"]
//            resources: [ .process("Resources") ]
        ),
    ]
)
