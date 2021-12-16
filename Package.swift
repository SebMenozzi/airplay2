// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AirPlayLib",
    platforms: [
        .macOS(.v11),
        .iOS(.v13)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/robbiehanson/CocoaAsyncSocket",
            from: "7.6.5"
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            .upToNextMajor(from: "1.4.2")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AirPlay",
            dependencies: [
                "CocoaAsyncSocket",
                "Curve25519",
                "CryptoSwift",
                "Ed25519"
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "Curve25519"
        ),
        .target(
            name: "Ed25519",
            dependencies: [
                "CEd25519"
            ]
        ),
        .target(
            name: "CEd25519"
        ),
        .testTarget(
            name: "AirPlayTests",
            dependencies: ["AirPlay"]
        )
    ]
)
