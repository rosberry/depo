//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class PodCommand: ParsableCommand {

    final class PodUpdate: Update {
        typealias Manager = PodManager

        static let configuration: CommandConfiguration = .init(commandName: "update", abstract: "run pod update and build pods")

        @OptionGroup()
        var options: Manager.Options

        static let depofileKeyPath: KeyPath<Depofile, [Pod]> = \.pods
    }

    final class PodInstall: Install {
        typealias Manager = PodManager

        static let configuration: CommandConfiguration = .init(commandName: "install", abstract: "run pod install and build pods")

        @OptionGroup()
        var options: Manager.Options

        static let depofileKeyPath: KeyPath<Depofile, [Pod]> = \.pods
    }

    final class PodBuild: Build {
        typealias Manager = PodManager
        static let configuration: CommandConfiguration = .init(commandName: "build", abstract: "build pods")

        @OptionGroup()
        var options: Manager.Options

        static let depofileKeyPath: KeyPath<Depofile, [Pod]> = \.pods
    }

    static let configuration: CommandConfiguration = .init(commandName: "pod",
                                                           abstract: "Pod wrapper",
                                                           subcommands: [PodUpdate.self,
                                                                         PodInstall.self,
                                                                         PodBuild.self],
                                                           defaultSubcommand: PodInstall.self)
}
