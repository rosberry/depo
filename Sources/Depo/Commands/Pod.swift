//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class Pod: ParsableCommand {

    final class PodUpdate: Update<PodManager> {
        override class var configuration: CommandConfiguration {
            .init(commandName: "update", abstract: "run pod update and build pods")
        }

        @OptionGroup()
        var options: PodManager.Options
    }

    final class PodInstall: Install<PodManager> {
        override class var configuration: CommandConfiguration {
            .init(commandName: "install", abstract: "run pod install and build pods")
        }

        @OptionGroup()
        var options: PodManager.Options
    }

    final class PodBuild: Build<PodManager> {
        override class var configuration: CommandConfiguration {
            .init(commandName: "build", abstract: "build pods")
        }

        @OptionGroup()
        var options: PodManager.Options
    }

    static let configuration: CommandConfiguration = .init(abstract: "Pod wrapper",
                                                           subcommands: [PodUpdate.self,
                                                                         PodInstall.self,
                                                                         PodBuild.self],
                                                           defaultSubcommand: PodInstall.self)
}
