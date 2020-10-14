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
        let installPods = InstallPods(pods: depofile.pods)
        let installCarthageItems = InstallCarthageItems(carthageItems: depofile.carts)
        try runSynchronously(installPodsCommand: installPods, installCarthageItemsCommand: installCarthageItems)
    }

    private func runSynchronously(installPodsCommand: InstallPods, installCarthageItemsCommand: InstallCarthageItems) throws {
        try CompositeRunner {
            installPodsCommand
            installCarthageItemsCommand
        }
    }
}
