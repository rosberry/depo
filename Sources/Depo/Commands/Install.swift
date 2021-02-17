//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

protocol Install: ParsableCommand, HasDepofileKeyPath {
    associatedtype Manager: HasInstallCommand, HasOptionsInit, ProgressObservable
    var options: Manager.Options { get }
}

extension Install where ValueType == [Manager.Package] {
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let manager = Manager(options: options).subscribe { state in
            print(state)
        }
        try manager.install(packages: depofile[keyPath: Self.depofileKeyPath])
    }
}
