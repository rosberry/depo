//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class Depo: ParsableCommand {

    final class Pods: ParsableCommand {
        static let configuration: CommandConfiguration = .init(subcommands: [Update<PodCommand>.self, Install<PodCommand>.self],
                                                               defaultSubcommand: Install<PodCommand>.self)
    }

    final class Carthage: ParsableCommand {
        static let configuration: CommandConfiguration = .init(subcommands: [Update<CarthageCommand>.self, Install<CarthageCommand>.self],
                                                               defaultSubcommand: Install<CarthageCommand>.self)
    }

    final class SPM: ParsableCommand {
        static let configuration: CommandConfiguration = .init(subcommands: [Update<SwiftPackageCommand>.self],
                                                               defaultSubcommand: Update<SwiftPackageCommand>.self)
    }

    final class AllUpdate: Update<AllCommand> {
        static let configuration: CommandConfiguration = .init(commandName: "update", abstract: "Update")
    }

    final class AllInstall: Install<AllCommand> {
        static let configuration: CommandConfiguration = .init(commandName: "install", abstract: "Install")
    }

    static let configuration: CommandConfiguration = .init(abstract: "Main",
                                                           version: "0.0",
                                                           subcommands: [AllUpdate.self,
                                                                         AllInstall.self,
                                                                         Pods.self,
                                                                         Carthage.self,
                                                                         SPM.self],
                                                           defaultSubcommand: Install<AllCommand>.self)
}
