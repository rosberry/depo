//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

class Update<Command: HasUpdateCommand & ProgressObservable>: ParsableCommand where Command.Options: ParsableArguments {

    class var configuration: CommandConfiguration {
        .init(commandName: "update")
    }

    @OptionGroup()
    var options: Command.Options

    required init() {}
    
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let command = Command(depofile: depofile, options: options).subscribe { state in
            print(state)
        }
        try command.update()
    }
}
