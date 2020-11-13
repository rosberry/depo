// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
        name: "Depo",
        platforms: [.macOS(.v10_15)],
        products: [
            .executable(name: "depo", targets: ["Depo"]),
            .library(name: "depo-core", targets: ["DepoCore"])
        ],
        dependencies: [
            // Dependencies declare other packages that this package depends on.
            // .package(url: /* package url */, from: "1.0.0"),
            .package(url: "https://github.com/apple/swift-argument-parser.git", .exact("0.3.1")),
            .package(url: "https://github.com/jpsim/Yams.git", .exact("4.0.0")),
            .package(url: "https://github.com/JohnSundell/Files", .exact("4.1.1"))
        ],
        targets: [
            // Targets are the basic building blocks of a package. A target can define a module or a test suite.
            // Targets can depend on other targets in this package, and on products in packages which this package depends on.
            .target(name: "Depo",
                    dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"),
                                   "DepoCore"]),
            .target(name: "DepoCore",
                    dependencies: [.product(name: "Yams", package: "Yams"),
                                   .product(name: "Files", package: "Files")]),
            .testTarget(name: "DepoTest",
                        dependencies: ["Depo"]
            )
        ]
)
