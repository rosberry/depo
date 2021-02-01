//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class Depo: ParsableCommand {

    final class AllInstall: Install {
        typealias Command = AllPackagesManager

        static let configuration: CommandConfiguration = .init(commandName: "install", abstract: "run install for all package managers")

        @OptionGroup()
        var options: Command.Options
    }

    final class AllUpdate: Update {
        typealias Command = AllPackagesManager

        static let configuration: CommandConfiguration = .init(commandName: "update", abstract: "run update for all package managers")

        @OptionGroup()
        var options: Command.Options
    }

    final class AllBuild: Build {
        typealias Command = AllPackagesManager

        static let configuration: CommandConfiguration = .init(commandName: "build", abstract: "run build for all package managers")

        @OptionGroup()
        var options: Command.Options
    }

    static let configuration: CommandConfiguration = .init(abstract: "Main",
                                                           version: "1.0.2",
                                                           subcommands: [Init.self,
                                                                         AllUpdate.self,
                                                                         AllInstall.self,
                                                                         AllBuild.self,
                                                                         Pod.self,
                                                                         Carthage.self,
                                                                         SPM.self,
                                                                         Example.self],
                                                           defaultSubcommand: AllInstall.self)
}
