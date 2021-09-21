//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

protocol Build: ParsableCommand {
    associatedtype Manager: PackageManager, HasOptionsInit, ProgressObservable where Manager.Package: GitIdentifiablePackage
    var options: Manager.Options { get }
}

extension Build {
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let wrapper = PackageManagerWrapper()
        let packages: [Manager.Package] = depofile[keyPath: Manager.keyPath]
        let manager = try wrapper.wrap(packages: packages,
                                       cacheBuilds: options.cacheBuilds,
                                       cacheURL: depofile.cacheURL) { _ in
            Manager(depofile: depofile, options: options).subscribe { state in
                print(state)
            }
        }
        let result = try manager.build()
        try throwIfNotNil(FailedPackagesError(buildResult: result))
    }
}
