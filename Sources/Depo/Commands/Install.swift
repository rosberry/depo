//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

protocol Install: ParsableCommand, HasDepofileKeyPath {
    associatedtype Command: HasInstallCommand, HasPackagesInit, ProgressObservable
    var options: Command.Options { get }
}

extension Install where ValueType == Command.Packages {
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let command = Command(packages: depofile[keyPath: Self.depofileKeyPath], options: options).subscribe { state in
            print(state)
        }
        try command.install()
    }
}
