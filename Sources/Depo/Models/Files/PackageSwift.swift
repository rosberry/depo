//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct PackageSwift: CustomStringConvertible {

    let description: String

    init(projectBuildSettings settings: BuildSettings, items: [SwiftPackage]) {
        let dependencies = items.map(Self.package).joined(separator: ",\n")
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

    private static func package(_ package: SwiftPackage) -> String {
        let version = ".\(package.versionConstraint.operation.rawValue)(\"\(package.versionConstraint.value)\")"
        return "    .package(name: \"\(package.name)\", url: \"\(package.url)\", \(version)"
    }

}
