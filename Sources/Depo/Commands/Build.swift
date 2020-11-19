//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class Build<Command: HasBuildCommand>: ParsableCommand {

    static var configuration: CommandConfiguration {
        .init(commandName: "build")
    }

    @OptionGroup()
    var options: Command.Options

    func run() throws {
        let depofile = try Depofile(decoder: options.depofileExtension.decoder)
        try Command(depofile: depofile, options: options).build()
    }
}
