// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "vapor-valkey",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
    ],
    products: [
        .library(name: "VaporValkey", targets: ["VaporValkey"])
    ],
    dependencies: [
        .package(url: "https://github.com/valkey-io/valkey-swift.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "5.0.0-beta.4", traits: []),
    ],
    targets: [
        .target(
            name: "VaporValkey",
            dependencies: [
                .product(name: "Valkey", package: "valkey-swift"),
                .product(name: "Vapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "VaporValkeyTests",
            dependencies: [
                .target(name: "VaporValkey"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] {
    [
        .strictMemorySafety(),
        .treatAllWarnings(as: .error),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("ImmutableWeakCaptures"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]
}
