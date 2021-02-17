//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

public struct AnyPackageManager<Package>: CanOutputPackages, HasAllCommands {

    public let outputPath: String
    let buildClosure: ([Package]) throws -> PackagesOutput<Package>
    let installClosure: ([Package]) throws -> PackagesOutput<Package>
    let updateClosure: ([Package]) throws -> PackagesOutput<Package>

    public func install(packages: [Package]) throws -> PackagesOutput<Package> {
        try installClosure(packages)
    }

    public func update(packages: [Package]) throws -> PackagesOutput<Package> {
        try updateClosure(packages)
    }

    public func build(packages: [Package]) throws -> PackagesOutput<Package> {
        try buildClosure(packages)
    }
}
