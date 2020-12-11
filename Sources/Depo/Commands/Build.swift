//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

protocol Build: ParsableCommand {
    associatedtype Command: HasBuildCommand, ProgressObservable
    var options: Command.Options { get }
}

extension Build {
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let command = Command(depofile: depofile, options: options).subscribe { state in
            print(state)
        }
        try command.build()
    }
}
