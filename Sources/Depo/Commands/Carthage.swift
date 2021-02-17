//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class Carthage: ParsableCommand {

    final class CarthageUpdate: Update {
        typealias Manager = GitCachablePackageManager<CarthageManager>
        static let  configuration: CommandConfiguration = .init(commandName: "update", abstract: "run carthage update")

        @OptionGroup()
        var options: Manager.Options

        static let depofileKeyPath: KeyPath<Depofile, [CarthageItem]> = \.carts
    }

    final class CarthageInstall: Install {
        typealias Manager = GitCachablePackageManager<CarthageManager>
        static let  configuration: CommandConfiguration = .init(commandName: "install", abstract: "run carthage bootstrap")

        @OptionGroup()
        var options: Manager.Options

        static let depofileKeyPath: KeyPath<Depofile, [CarthageItem]> = \.carts
    }

    final class CarthageBuild: Build {
        typealias Manager = GitCachablePackageManager<CarthageManager>
        static let  configuration: CommandConfiguration = .init(commandName: "build", abstract: "run carthage build")

        @OptionGroup()
        var options: Manager.Options

        static let depofileKeyPath: KeyPath<Depofile, [CarthageItem]> = \.carts
    }

    static let configuration: CommandConfiguration = .init(abstract: "Carthage wrapper",
                                                           subcommands: [CarthageUpdate.self,
                                                                         CarthageInstall.self,
                                                                         CarthageBuild.self],
                                                           defaultSubcommand: CarthageInstall.self)
}
