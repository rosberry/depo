//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

struct AnyPackageManager<Package>: CanOutputPackages, HasAllCommands {

    let outputPath: String
    let buildClosure: ([Package]) throws -> PackagesOutput<Package>
    let installClosure: ([Package]) throws -> PackagesOutput<Package>
    let updateClosure: ([Package]) throws -> PackagesOutput<Package>

    func install(packages: [Package]) throws -> PackagesOutput<Package> {
        try installClosure(packages)
    }

    func update(packages: [Package]) throws -> PackagesOutput<Package> {
        try updateClosure(packages)
    }

    func build(packages: [Package]) throws -> PackagesOutput<Package> {
        try buildClosure(packages)
    }
}
