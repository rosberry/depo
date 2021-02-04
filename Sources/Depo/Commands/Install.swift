//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

protocol Install: ParsableCommand, HasDepofileKeyPath {
    associatedtype Command: HasInstallCommand, HasOptionsInit, ProgressObservable
    var options: Command.Options { get }
}

extension Install where ValueType == [Command.Package] {
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let command = Command(options: options).subscribe { state in
            print(state)
        }
        try command.install(packages: depofile[keyPath: Self.depofileKeyPath])
    }
}
