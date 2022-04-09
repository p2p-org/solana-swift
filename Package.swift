// swift-tools-version:5.4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SolanaSwift",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SolanaSwift",
            targets: ["SolanaSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.4.1")),
        .package(url: "https://github.com/bigearsenal/BufferLayoutSwift.git", .upToNextMajor(from: "0.9.0")),
        .package(name: "secp256k1", url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.0"),
        .package(name: "TweetNacl", url: "https://github.com/bitmark-inc/tweetnacl-swiftwrap.git", from: "1.0.2"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxAlamofire.git",
                             from: "6.1.1"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SolanaSwift",
            dependencies: ["CryptoSwift", "BufferLayoutSwift", "secp256k1", "TweetNacl", "RxSwift", .product(name: "RxCocoa", package: "RxSwift"), "RxAlamofire", "Starscream"],
            resources: [ .process("Resources") ]
        ),
        .testTarget(
            name: "SolanaSwiftTests",
            dependencies: ["SolanaSwift", "BufferLayoutSwift", "secp256k1", "TweetNacl", "RxSwift", .product(name: "RxBlocking", package: "RxSwift")],
            resources: [ .process("Resources") ]
        ),
    ]
)
