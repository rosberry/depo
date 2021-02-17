//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class SPM: ParsableCommand {

    final class SPMUpdate: Update {
        typealias Manager = GitCachablePackageManager<SPMManager>
        static let configuration: CommandConfiguration = .init(commandName: "update",
                                                               abstract: "run swift package update and build swift packages")

        @OptionGroup()
        var options: Manager.Options

        static let depofileKeyPath: KeyPath<Depofile, [SwiftPackage]> = \.swiftPackages
    }

    final class SPMBuild: Build {
        typealias Manager = GitCachablePackageManager<SPMManager>
        static let configuration: CommandConfiguration = .init(commandName: "build", abstract: "build swift packages")

        @OptionGroup()
        var options: Manager.Options

        static let depofileKeyPath: KeyPath<Depofile, [SwiftPackage]> = \.swiftPackages
    }

    static let configuration: CommandConfiguration = .init(abstract: "SPM wrapper",
                                                           subcommands: [SPMUpdate.self,
                                                                         SPMBuild.self],
                                                           defaultSubcommand: SPMUpdate.self)
}
