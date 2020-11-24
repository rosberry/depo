//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class Depo: ParsableCommand {

    typealias AllUpdate = Update<AllPackagesManager>
    typealias AllInstall = Install<AllPackagesManager>
    typealias AllBuild = Build<AllPackagesManager>

    final class Pod: ParsableCommand {
        static let configuration: CommandConfiguration = .init(subcommands: [Update<PodManager>.self,
                                                                             Install<PodManager>.self,
                                                                             Build<PodManager>.self],
                                                               defaultSubcommand: Install<PodManager>.self)
    }

    final class Carthage: ParsableCommand {
        static let configuration: CommandConfiguration = .init(subcommands: [Update<CarthageManager>.self,
                                                                             Install<CarthageManager>.self,
                                                                             Build<CarthageManager>.self],
                                                               defaultSubcommand: Install<CarthageManager>.self)
    }

    final class SPM: ParsableCommand {
        static let configuration: CommandConfiguration = .init(subcommands: [Update<SPMManager>.self, Build<SPMManager>.self],
                                                               defaultSubcommand: Update<SPMManager>.self)
    }

    static let configuration: CommandConfiguration = .init(abstract: "Main",
                                                           version: "0.0",
                                                           subcommands: [Init.self,
                                                                         AllUpdate.self,
                                                                         AllInstall.self,
                                                                         AllBuild.self,
                                                                         Pod.self,
                                                                         Carthage.self,
                                                                         SPM.self],
                                                           defaultSubcommand: Install<AllPackagesManager>.self)
}
