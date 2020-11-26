// swift-tools-version:test-swift-version

import PackageDescription

let package = Package(name: "Test",
                      products: [.library(name: "Test",
                                          targets: ["TestTarget"])],
                      dependencies: [],
                      targets: [.target(name: "Test",
                                        dependencies: [])])
