//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

class UpdateParsableCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(commandName: "update")
    required init() {}
    func run() throws {
        print(#function)
    }
}

class InstallParsableCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(commandName: "install")
    required init() {}
    func run() throws {
        print(#function)
    }
}

class Update<Command: HasUpdateCommand>: UpdateParsableCommand {
    override func run() throws {
        let depofile = try Depofile(decoder: DataDecoder.Kind.yaml.decoder)
        try Command(depofile: depofile).update()
    }
}

class Install<Command: HasInstallCommand>: InstallParsableCommand {
    override func run() throws {
        let depofile = try Depofile(decoder: DataDecoder.Kind.yaml.decoder)
        try Command(depofile: depofile).install()
    }
}
