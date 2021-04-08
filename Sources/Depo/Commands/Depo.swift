//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class Depo: ParsableCommand {

    final class AllInstall: Install {
        typealias Manager = AllPackagesManager

        static let configuration: CommandConfiguration = .init(commandName: "install", abstract: "run install for all package managers")

        @OptionGroup()
        var options: Manager.Options

        public static let depofileKeyPath: KeyPath<Depofile, [Depofile]> = \.array
    }

    final class AllUpdate: Update {
        typealias Manager = AllPackagesManager

        static let configuration: CommandConfiguration = .init(commandName: "update", abstract: "run update for all package managers")

        @OptionGroup()
        var options: Manager.Options

        public static let depofileKeyPath: KeyPath<Depofile, [Depofile]> = \.array
    }

    final class AllBuild: Build {
        typealias Manager = AllPackagesManager

        static let configuration: CommandConfiguration = .init(commandName: "build", abstract: "run build for all package managers")

        @OptionGroup()
        var options: Manager.Options

        public static let depofileKeyPath: KeyPath<Depofile, [Depofile]> = \.array
    }

    static let configuration: CommandConfiguration = .init(abstract: "Main",
                                                           version: "1.1.0",
                                                           subcommands: [Init.self,
                                                                         AllUpdate.self,
                                                                         AllInstall.self,
                                                                         AllBuild.self,
                                                                         PodCommand.self,
                                                                         Carthage.self,
                                                                         SPM.self,
                                                                         Cacher.self,
                                                                         Example.self],
                                                           defaultSubcommand: AllInstall.self)
}
