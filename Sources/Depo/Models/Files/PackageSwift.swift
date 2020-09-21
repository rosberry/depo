//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct PackageSwift: CustomStringConvertible {

    let description: String

    init(projectBuildSettings settings: BuildSettings, items: [SwiftPackage]) {
        let dependencies = items.map { item in
            "    .package(url: \"\(item.url)\", .exact(\"\(item.exactVersion)\"))"
        }.joined(separator: ",\n")
        self.description = """
                           // swift-tools-version:\(settings.swiftVersion)

                           import PackageDescription

                           let package = Package(
                               name: "\(settings.productName)",
                               products: [.library(name: "\(settings.productName)",
                                                   targets: ["\(settings.targetName)"])],
                               dependencies: [
                               \(dependencies)
                               ],
                               targets: [.target(name: "\(settings.productName)",
                                                 dependencies: [])
                               ]
                           )
                           """
    }

}
