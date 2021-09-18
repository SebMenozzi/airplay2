// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AirPlay2",
    platforms: [
        .macOS(.v11),
        .iOS(.v13)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/robbiehanson/CocoaAsyncSocket",
            from: "7.6.4"
        ),
        .package(
            url: "https://github.com/Bouke/SRP",
            .branch("master")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AirPlay2",
            dependencies: [
                "CocoaAsyncSocket",
                "CryptoBindings",
                "SRP"
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "CryptoBindings",
            dependencies: [
                "Curve25519",
                "ed25519"
            ],
            exclude: ["SwiftSources"],
            cSettings: [
                .headerSearchPath("include"),
            ]
        ),
        .target(
            name: "Curve25519"
        ),
        .target(
            name: "ed25519",
            exclude: ["sha512/LICENSE.txt"]
        ),
        .testTarget(
            name: "AirPlay2Tests",
            dependencies: ["AirPlay2"]
        )
    ]
)
