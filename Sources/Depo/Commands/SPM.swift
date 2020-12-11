//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class SPM: ParsableCommand {

    final class SPMUpdate: Update {
        typealias Command = SPMManager
        static let configuration: CommandConfiguration = .init(commandName: "update", abstract: "run swift package update and build swift packages")

        @OptionGroup()
        var options: Command.Options
    }

    final class SPMBuild: Build {
        typealias Command = SPMManager
        static let configuration: CommandConfiguration = .init(commandName: "build", abstract: "build swift packages")

        @OptionGroup()
        var options: Command.Options
    }
    
    static let configuration: CommandConfiguration = .init(abstract: "SPM wrapper",
                                                           subcommands: [SPMUpdate.self,
                                                                         SPMBuild.self],
                                                           defaultSubcommand: SPMUpdate.self)
}
