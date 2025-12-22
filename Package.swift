// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "VaporValkey",
    platforms: [
        .macOS(.v15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "VaporValkey",
            targets: ["VaporValkey"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.0.0"),
        .package(url: "https://github.com/valkey-io/valkey-swift.git", "0.5.0" ..< "0.6.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.100.0"),
    ],
    targets: [
        .target(
            name: "VaporValkey",
            dependencies: [
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "Valkey", package: "valkey-swift"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(
            name: "VaporValkeyTests",
            dependencies: [
                "VaporValkey",
                .product(name: "VaporTesting", package: "vapor"),
            ]
        ),
    ]
)
