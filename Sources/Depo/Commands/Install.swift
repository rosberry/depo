//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

class Install<Command: HasInstallCommand & ProgressObservable>: ParsableCommand where Command.Options: ParsableArguments {

    class var configuration: CommandConfiguration {
        .init(commandName: "install")
    }

    @OptionGroup()
    var options: Command.Options

    required init() {}
    
    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.coder)
        let command = Command(depofile: depofile, options: options).subscribe { state in
            print(state)
        }
        try command.install()
    }
}
