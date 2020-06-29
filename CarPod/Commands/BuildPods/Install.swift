//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation
import ArgumentParser

struct Install: ParsableCommand {

    func run() throws {
        let carPodfile = try CarPodfile()
        let installPods = InstallPods(pods: carPodfile.pods)
        let installCarthageItems = InstallCarthageItems(carthageItems: carPodfile.carts)
        DispatchQueue.global(qos: .default).async {
            do {
                try installPods.run()
                print("pods")
            }
            catch {
                print(error)
            }
        }
        DispatchQueue.global(qos: .default).async {
            do {
                try installCarthageItems.run()
                print("carthage")
            }
            catch {
                print(error)
            }
        }
        RunLoop.main.run()
    }
}
