//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

protocol Update: ParsableCommand, HasDepofileKeyPath {
    associatedtype Command: HasUpdateCommand, HasOptionsInit, ProgressObservable
    var options: Command.Options { get }
}

extension Update where ValueType == Command.Packages {
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let command = Command(options: options).subscribe { state in
            print(state)
        }
        try command.update(packages: depofile[keyPath: Self.depofileKeyPath])
    }
}
