//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

protocol Install: ParsableCommand {
    associatedtype Manager: PackageManager, HasOptionsInit, ProgressObservable where Manager.Package: GitIdentifiablePackage
    var options: Manager.Options { get }
}

extension Install {
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let wrapper = PackageManagerWrapper()
        let packages: [Manager.Package] = depofile[keyPath: Manager.keyPath]
        let manager = try wrapper.wrap(packages: packages,
                                       cacheBuilds: options.cacheBuilds,
                                       cacheURL: depofile.cacheURL) { packages in
            Manager(depofile: depofile, options: options).subscribe { state in
                print(state)
            }
        }
        _ = try manager.install()
    }
}
