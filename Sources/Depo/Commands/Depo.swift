//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class Depo: ParsableCommand {

    typealias AllUpdate = Update<AllPackagesManager>
    typealias AllInstall = Install<AllPackagesManager>

    final class Pods: ParsableCommand {
        static let configuration: CommandConfiguration = .init(subcommands: [Update<PodManager>.self, Install<PodManager>.self],
                                                               defaultSubcommand: Install<PodManager>.self)
    }

    final class Carthage: ParsableCommand {
        static let configuration: CommandConfiguration = .init(subcommands: [Update<CarthageManager>.self, Install<CarthageManager>.self],
                                                               defaultSubcommand: Install<CarthageManager>.self)
    }

    final class SPM: ParsableCommand {
        static let configuration: CommandConfiguration = .init(subcommands: [Update<SPMManager>.self],
                                                               defaultSubcommand: Update<SPMManager>.self)
    }

    static let configuration: CommandConfiguration = .init(abstract: "Main",
                                                           version: "0.0",
                                                           subcommands: [AllUpdate.self,
                                                                         AllInstall.self,
                                                                         Pods.self,
                                                                         Carthage.self,
                                                                         SPM.self],
                                                           defaultSubcommand: Install<AllPackagesManager>.self)
}
