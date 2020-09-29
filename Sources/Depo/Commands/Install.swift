//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class Install: ParsableCommand {

    @OptionGroup()
    private(set) var options: Options

    func run() throws {
        let depofile = try Depofile(decoder: options.depoFileType.decoder)
        let podCommand = PodCommand(pods: depofile.pods)
        let carthageCommand = CarthageCommand(carthageItems: depofile.carts)
        try runSynchronously(installPodsCommand: podCommand, installCarthageItemsCommand: carthageCommand)
    }

    private func runSynchronously(installPodsCommand: PodCommand, installCarthageItemsCommand: CarthageCommand) throws {
        try CompositeError {
            installPodsCommand.install
            installCarthageItemsCommand.update
        }
    }
}
