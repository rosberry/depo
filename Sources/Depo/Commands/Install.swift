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

    private func runParallel(installPodsCommand: InstallPods, installCarthageItemsCommand: InstallCarthageItems) throws {
        let group = DispatchGroup()
        let syncQueue: DispatchQueue = .init(label: "sync")
        var errors: [Error] = []

        func run(task: @escaping () throws -> Void) {
            let queue = DispatchQueue.global(qos: .userInitiated)
            queue.async(group: group) {
                do {
                    try task()
                }
                catch {
                    syncQueue.sync {
                        errors.append(error)
                    }
                }
            }
        }

        run {
            try installPodsCommand.run()
        }

        run {
            try installPodsCommand.run()
        }
        group.wait()
        try CompositeError(errors: errors)
    }
}