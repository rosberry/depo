// swift-tools-version:test-swift-version

import PackageDescription

let package = Package(name: "Test",
                      products: [.library(name: "Test",
                                          targets: ["TestTarget"])],
                      dependencies: [.package(name: "test-package-1", url: "file://test-package-1", .exact("0.0.1")),
                                     .package(name: "test-package-2", url: "file://test-package-2", .upToNextMinor(from: "0.1.0")),
                                     .package(name: "test-package-3", url: "file://test-package-3", .upToNextMajor(from: "0.1.1")),
                                     .package(name: "test-package-4", url: "file://test-package-4", .branch("test-package-4-branch")),
                                     .package(name: "test-package-5", url: "file://test-package-5", .revision("test-package-5-commit-hash"))],
                      targets: [.target(name: "Test",
                                        dependencies: [])])
