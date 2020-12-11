//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class Pod: ParsableCommand {

    final class PodUpdate: Update {
        typealias Command = PodManager

        static let configuration: CommandConfiguration = .init(commandName: "update", abstract: "run pod update and build pods")

        @OptionGroup()
        var options: PodManager.Options
    }

    final class PodInstall: Install {
        typealias Command = PodManager

        static let configuration: CommandConfiguration = .init(commandName: "install", abstract: "run pod install and build pods")

        @OptionGroup()
        var options: Command.Options
    }

    final class PodBuild: Build {
        typealias Command = PodManager
        static let configuration: CommandConfiguration = .init(commandName: "build", abstract: "build pods")

        @OptionGroup()
        var options: Command.Options
    }

    static let configuration: CommandConfiguration = .init(abstract: "Pod wrapper",
                                                           subcommands: [PodUpdate.self,
                                                                         PodInstall.self,
                                                                         PodBuild.self],
                                                           defaultSubcommand: PodInstall.self)
}
