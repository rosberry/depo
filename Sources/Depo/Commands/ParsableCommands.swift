//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

class UpdateParsableCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(commandName: "update")
    required init() {}
}

class InstallParsableCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(commandName: "install")
    required init() {}
}

class Update<Command: HasUpdateCommand>: UpdateParsableCommand {
    @OptionGroup()
    private var options: Options

    func run() throws {
        let depofile = try Depofile(decoder: options.depoFileType.decoder)
        try Command(depofile: depofile).update()
    }
}

class Install<Command: HasInstallCommand>: InstallParsableCommand {
    @OptionGroup()
    private var options: Options

    func run() throws {
        let depofile = try Depofile(decoder: options.depoFileType.decoder)
        try Command(depofile: depofile).install()
    }
}
