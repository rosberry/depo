// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
        name: "Depo",
        platforms: [.macOS(.v10_15)],
        products: [
            .executable(name: "Depo", targets: ["Depo"]),
            .library(name: "DepoCore", targets: ["DepoCore"]),
            .library(name: "CartfileParser", targets: ["CartfileParser"])
        ],
        dependencies: [
            .package(url: "https://github.com/apple/swift-argument-parser.git", .exact("0.3.1")),
            .package(url: "https://github.com/jpsim/Yams.git", .exact("4.0.0")),
            .package(url: "https://github.com/JohnSundell/Files", .exact("4.1.1"))
        ],
        targets: [
            .target(name: "Depo",
                    dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"),
                                   "DepoCore"]),
            .target(name: "DepoCore",
                    dependencies: [.product(name: "Yams", package: "Yams"),
                                   .product(name: "Files", package: "Files"),
                                   .target(name: "CartfileParser")]),
            .target(name: "CartfileParser"),
            .testTarget(name: "DepoTest",
                        dependencies: ["DepoCore", "Depo"],
                        resources: [.copy("Resources")]),
            .testTarget(name: "CartfileParserTest",
                        dependencies: ["CartfileParser"],
                        resources: [.copy("Resources")])
        ]
)
