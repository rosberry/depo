//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class Install: ParsableCommand {

    @OptionGroup()
    private(set) var options: Options

    func run() throws {
        let carPodfile = try CarPodfile(decoder: options.carpodFileType.decoder)
        let installPods = InstallPods(pods: carPodfile.pods)
        let installCarthageItems = InstallCarthageItems(carthageItems: carPodfile.carts)
        try runSynchronously(installPodsCommand: installPods, installCarthageItemsCommand: installCarthageItems)
    }

    private func runSynchronously(installPodsCommand: InstallPods, installCarthageItemsCommand: InstallCarthageItems) throws {
        try CompositeError {
            installPodsCommand.run
            installCarthageItemsCommand.run
        }
    }
}
