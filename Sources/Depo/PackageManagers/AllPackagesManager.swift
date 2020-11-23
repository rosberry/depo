//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class AllPackagesManager {

    private let depofile: Depofile
    private let platform: Platform
    private var podManager: PodManager {
        .init(depofile: depofile)
    }
    private var carthageManager: CarthageManager {
        .init(depofile: depofile, platform: platform)
    }
    private var spmManager: SPMManager {
        .init(depofile: depofile)
    }

    public init(depofile: Depofile, platform: Platform) {
        self.depofile = depofile
        self.platform = platform
    }

    public func update() throws {
        try CommandRunner.runIndependently {
            podManager.update
            carthageManager.update
            spmManager.update
        }
    }

    public func install() throws {
        try CommandRunner.runIndependently {
            podManager.install
            carthageManager.install
            spmManager.update
        }
    }

    public func build() throws {
        try CommandRunner.runIndependently {
            podManager.build
            carthageManager.build
            spmManager.build
        }
    }
}
