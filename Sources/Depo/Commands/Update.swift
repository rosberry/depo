//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

protocol Update: ParsableCommand, HasDepofileKeyPath {
    associatedtype Manager: HasUpdateCommand, HasOptionsInit, ProgressObservable where Manager.Package: GitIdentifiablePackage
    var options: Manager.Options { get }
}

extension Update where ValueType == [Manager.Package] {
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let manager = Manager(options: options).subscribe { state in
            print(state)
        }
        let wrapper = PackageManagerWrapper()
        try wrapper(manager: manager, cacheBuilds: options.cacheBuilds).update(packages: depofile[keyPath: Self.depofileKeyPath])
    }
}
