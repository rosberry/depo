//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import ArgumentParser

struct Install: ParsableCommand {

    enum CustomErrors: LocalizedError {
        case composition(errors: [Error])
    }

    func run() throws {
        let carPodfile = try CarPodfile()
        let installPods = InstallPods(pods: carPodfile.pods)
        let installCarthageItems = InstallCarthageItems(carthageItems: carPodfile.carts)
        try runSynchronously(installPodsCommand: installPods, installCarthageItemsCommand: installCarthageItems)
    }

    private func runSynchronously(installPodsCommand: InstallPods, installCarthageItemsCommand: InstallCarthageItems) throws {
        try installPodsCommand.run()
        try installCarthageItemsCommand.run()
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
        if !errors.isEmpty {
            throw CustomErrors.composition(errors: errors)
        }
    }
}
