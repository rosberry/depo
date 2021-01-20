//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class Carthage: ParsableCommand {

    final class CarthageUpdate: Update {
        typealias Command = CarthageManager
        static let  configuration: CommandConfiguration = .init(commandName: "update", abstract: "run carthage update")

        @OptionGroup()
        var options: Command.Options
    }

    final class CarthageInstall: Install {
        typealias Command = CarthageManager
        static let  configuration: CommandConfiguration = .init(commandName: "install", abstract: "run carthage bootstrap")

        @OptionGroup()
        var options: Command.Options
    }

    final class CarthageBuild: Build {
        typealias Command = CarthageManager
        static let  configuration: CommandConfiguration = .init(commandName: "build", abstract: "run carthage build")

        @OptionGroup()
        var options: Command.Options
    }

    static let configuration: CommandConfiguration = .init(abstract: "Carthage wrapper",
                                                           subcommands: [CarthageUpdate.self,
                                                                         CarthageInstall.self,
                                                                         CarthageBuild.self],
                                                           defaultSubcommand: CarthageInstall.self)
}
