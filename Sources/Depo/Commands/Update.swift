//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class Update<Command: HasUpdateCommand>: ParsableCommand where Command.Options: ParsableArguments {

    static var configuration: CommandConfiguration {
        .init(commandName: "update")
    }

    @OptionGroup()
    var options: Command.Options

    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        try Command(depofile: depofile, options: options).update()
    }
}