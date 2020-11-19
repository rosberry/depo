//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

final class AllPackagesManager: PackageManager {

    struct Options: HasDepofileExtension, ParsableArguments {
        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                help: "\(DataCoder.Kind.allFlagsHelp)")
        var depofileExtension: DataCoder.Kind = .defaultValue

        @Option(name: [.customLong("platform"), .customShort(Character("p"))],
                help: "\(Platform.allFlagsHelp)")
        var platform: Platform = .defaultValue
    }

    private let depofile: Depofile
    private let options: Options
    private var podManager: PodManager {
        .init(depofile: depofile)
    }
    private var carthageManager: CarthageManager {
        .init(depofile: depofile, platform: options.platform)
    }
    private var spmManager: SPMManager {
        .init(depofile: depofile)
    }

    init(depofile: Depofile, options: Options) {
        self.depofile = depofile
        self.options = options
    }

    func update() throws {
        try CommandRunner.runIndependently {
            podManager.update
            carthageManager.update
            spmManager.update
        }
    }

    func install() throws {
        try CommandRunner.runIndependently {
            podManager.install
            carthageManager.install
            spmManager.update
        }
    }

    func build() throws {
        try CommandRunner.runIndependently {
            podManager.build
            carthageManager.build
            spmManager.build
        }
    }
}
