// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Models",
            targets: ["Models"]
        ),
    ],
    dependencies: [
        .package(name: "API", path: "../API"),
        .package(url: "https://github.com/marcoarment/Blackbird", branch: "main"),
        .package(url: "https://github.com/nakajima/pat.swift", branch: "main"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", branch: "master"),
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Models",
            dependencies: [
                "API",
                "KeychainAccess",
                .product(name: "pat.swift", package: "pat.swift"),
                .product(name: "Blackbird", package: "Blackbird"),
                .product(name: "Apollo", package: "apollo-ios"),
            ]
        ),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models"]
        ),
    ]
)
