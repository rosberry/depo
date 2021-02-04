//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

protocol Build: ParsableCommand, HasDepofileKeyPath {
    associatedtype Command: HasBuildCommand, HasOptionsInit, ProgressObservable
    var options: Command.Options { get }
}

extension Build where ValueType == [Command.Package] {
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let command = Command(options: options).subscribe { state in
            print(state)
        }
        try command.build(packages: depofile[keyPath: Self.depofileKeyPath])
    }
}
