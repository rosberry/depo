//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class SPM: ParsableCommand {

    final class SPMUpdate: Update {
        typealias Command = GitCachablePackageManager<SPMManager, SwiftPackage>
        static let configuration: CommandConfiguration = .init(commandName: "update",
                                                               abstract: "run swift package update and build swift packages")

        @OptionGroup()
        var options: Command.Options

        static let depofileKeyPath: KeyPath<Depofile, [SwiftPackage]> = \.swiftPackages
    }

    final class SPMBuild: Build {
        typealias Command = GitCachablePackageManager<SPMManager, SwiftPackage>
        static let configuration: CommandConfiguration = .init(commandName: "build", abstract: "build swift packages")

        @OptionGroup()
        var options: Command.Options

        static let depofileKeyPath: KeyPath<Depofile, [SwiftPackage]> = \.swiftPackages
    }

    static let configuration: CommandConfiguration = .init(abstract: "SPM wrapper",
                                                           subcommands: [SPMUpdate.self,
                                                                         SPMBuild.self],
                                                           defaultSubcommand: SPMUpdate.self)
}
