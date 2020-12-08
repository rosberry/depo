//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class Depo: ParsableCommand {

    final class AllInstall: Install<AllPackagesManager> {
        override class var configuration: CommandConfiguration {
            .init(commandName: "install", abstract: "run install for all package managers")
        }
    }

    final class AllUpdate: Update<AllPackagesManager> {
        override class var configuration: CommandConfiguration {
            .init(commandName: "update", abstract: "run update for all package managers")
        }
    }

    final class AllBuild: Build<AllPackagesManager> {
        override class var configuration: CommandConfiguration {
            .init(commandName: "build", abstract: "run build for all package managers")
        }
    }

    static let configuration: CommandConfiguration = .init(abstract: "Main",
                                                           version: "1.0.2",
                                                           subcommands: [Init.self,
                                                                         AllUpdate.self,
                                                                         AllInstall.self,
                                                                         AllBuild.self,
                                                                         Pod.self,
                                                                         Carthage.self,
                                                                         SPM.self],
                                                           defaultSubcommand: AllInstall.self)
}
