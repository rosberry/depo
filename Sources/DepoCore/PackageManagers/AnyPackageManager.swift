//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

public struct AnyPackageManager<Package>: PackageManager {

    static public var outputPath: String {
        ""
    }
    public let packages: [Package]
    let buildClosure: () throws -> PackagesOutput<Package>
    let installClosure: () throws -> PackagesOutput<Package>
    let updateClosure: () throws -> PackagesOutput<Package>

    init<PM: PackageManager>(packageManager: PM) where PM.Package == Package {
        packages = packageManager.packages
        buildClosure = packageManager.build
        installClosure = packageManager.install
        updateClosure = packageManager.update
    }

    public func install() throws -> PackagesOutput<Package> {
        try installClosure()
    }

    public func update() throws -> PackagesOutput<Package> {
        try updateClosure()
    }

    public func build() throws -> PackagesOutput<Package> {
        try buildClosure()
    }
}
