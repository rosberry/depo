//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class Carthage: ParsableCommand {

    final class CarthageUpdate: Update<CarthageManager> {
        override class var configuration: CommandConfiguration {
            .init(commandName: "update", abstract: "run carthage update")
        }

        @OptionGroup()
        override var options: CarthageManager.Options
    }

    final class CarthageInstall: Install<CarthageManager> {
        override class var configuration: CommandConfiguration {
            .init(commandName: "install", abstract: "run carthage bootstrap")
        }

        @OptionGroup()
        var options: CarthageManager.Options
    }

    final class CarthageBuild: Build<CarthageManager> {
        override class var configuration: CommandConfiguration {
            .init(commandName: "build", abstract: "run carthage build")
        }

        @OptionGroup()
        var options: CarthageManager.Options
    }

    static let configuration: CommandConfiguration = .init(abstract: "Carthage wrapper",
                                                           subcommands: [CarthageUpdate.self,
                                                                         CarthageInstall.self,
                                                                         CarthageBuild.self],
                                                           defaultSubcommand: CarthageInstall.self)
}
