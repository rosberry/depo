//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class AllPackagesManager: ProgressObservable {

    public enum State {
        case podManager(PodManager.State)
        case carthageManager(CarthageManager.State)
        case spmManager(SPMManager.State)
    }

    private let depofile: Depofile
    private let platform: Platform
    private var podManager: PodManager {
        PodManager(depofile: depofile).subscribe { [weak self] state in
            self?.observer?(.podManager(state))
        }
    }
    private var carthageManager: CarthageManager {
        CarthageManager(depofile: depofile, platform: platform).subscribe { [weak self] state in
            self?.observer?(.carthageManager(state))
        }
    }
    private var spmManager: SPMManager {
        SPMManager(depofile: depofile).subscribe { [weak self] state in
            self?.observer?(.spmManager(state))
        }
    }
    private var observer: ((State) -> Void)?

    public init(depofile: Depofile, platform: Platform) {
        self.depofile = depofile
        self.platform = platform
    }

    public func subscribe(_ observer: @escaping (State) -> Void) -> AllPackagesManager {
        self.observer = observer
        return self
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
