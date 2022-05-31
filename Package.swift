// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "VaporBase",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "VaporBase",
            targets: ["VaporBase"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Coercion", from: "1.0.0"),
//        .package(url: "https://github.com/elegantchaos/Runner", from: "1.0.0"),
        
        // 💧 Vapor.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.60.3"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.4.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.2.6"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.2.0"),
    ],
    targets: [
        .target(
            name: "VaporBase",
            dependencies: [
                .product(name: "Coercion", package: "Coercion"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
//                .product(name: "Runner", package: "Runner")
            ],
            resources: [
                .copy("Resources/Views")
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "VaporBase"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
