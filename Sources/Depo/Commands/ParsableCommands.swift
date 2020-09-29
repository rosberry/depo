//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

class Update<Command: UpdatePackageManagerCommand>: ParsableCommand {
    @OptionGroup()
    private var options: Options

    required init() {}

    func run() throws {
        let depofile = try Depofile(decoder: options.depoFileType.decoder)
        try Command(depofile: depofile).update()
    }
}

class Install<Command: InstallPackageManagerCommand>: ParsableCommand {
    @OptionGroup()
    private var options: Options

    static let configuration: CommandConfiguration = .init(commandName: "install")

    required init() {}

    func run() throws {
        let depofile = try Depofile(decoder: options.depoFileType.decoder)
        try Command(depofile: depofile).install()
    }
}
