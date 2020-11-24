//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct PackageSwift: CustomStringConvertible {

    public let description: String
    public let packages: [SwiftPackage]

    public init(projectBuildSettings settings: BuildSettings, packages: [SwiftPackage]) {
        self.packages = packages
        let dependencies = packages.map(Self.package).joined(separator: ",\n\(Self.tabs(9)) ")
        self.description = """
                           // swift-tools-version:\(settings.systemSwiftVersion)

                           import PackageDescription

                           let package = Package(name: "\(settings.productName)",
                                                 products: [.library(name: "\(settings.productName)",
                                                                     targets: ["\(settings.targetName)"])],
                                                 dependencies: [\(dependencies)],
                                                 targets: [.target(name: "\(settings.productName)",
                                                                   dependencies: [])])

                           """
    }

    private static func package(_ package: SwiftPackage) -> String {
        let version = package.versionConstraint.map { self.version($0) } ?? ""
        return ".package(name: \"\(package.name)\", url: \"\(package.url)\", \(version))"
    }

    private static func tabs(_ count: UInt, tabWidth: Int = 4) -> String {
        (0..<count).reduce("") { result, _ in
            result + Array(repeating: Character(" "), count: tabWidth)
        }
    }

    private static func version(_ versionConstraint: VersionConstraint<SwiftPackage.Operator>) -> String {
        switch versionConstraint.operation {
        case .upToNextMinor,
             .upToNextMajor:
            return ".\(versionConstraint.operation.rawValue)(from: \"\(versionConstraint.value)\")"
        default:
            return ".\(versionConstraint.operation.rawValue)(\"\(versionConstraint.value)\")"
        }
    }
}
