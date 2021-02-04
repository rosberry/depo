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
        PodManager(depofile: depofile,
                   podCommandPath: podCommandPath,
                   frameworkKind: frameworkKind,
                   cacheBuilds: cacheBuilds,
                   podArguments: podArguments).subscribe { [weak self] state in
            self?.observer?(.podManager(state))
        }
    }
    private var carthageManager: CarthageManager {
        CarthageManager(depofile: depofile,
                        platform: platform,
                        carthageCommandPath: carthageCommandPath,
                        cacheBuilds: cacheBuilds,
                        carthageArguments: carthageArguments).subscribe { [weak self] state in
            self?.observer?(.carthageManager(state))
        }
    }
    private var spmManager: SPMManager {
        SPMManager(depofile: depofile,
                   swiftCommandPath: swiftCommandPath,
                   frameworkKind: frameworkKind,
                   cacheBuilds: cacheBuilds,
                   swiftBuildArguments: swiftBuildArguments).subscribe { [weak self] state in
            self?.observer?(.spmManager(state))
        }
    }
    private var observer: ((State) -> Void)?
    private let podCommandPath: String
    private let carthageCommandPath: String
    private let swiftCommandPath: String
    private let frameworkKind: MergePackage.FrameworkKind
    private let cacheBuilds: Bool
    private let carthageArguments: String?
    private let podArguments: String?
    private let swiftBuildArguments: String?

    public init(depofile: Depofile,
                platform: Platform,
                podCommandPath: String,
                carthageCommandPath: String,
                swiftCommandPath: String,
                frameworkKind: MergePackage.FrameworkKind,
                cacheBuilds: Bool,
                carthageArguments: String?,
                podArguments: String?,
                swiftBuildArguments: String?) {
        self.depofile = depofile
        self.platform = platform
        self.podCommandPath = podCommandPath
        self.carthageCommandPath = carthageCommandPath
        self.swiftCommandPath = swiftCommandPath
        self.frameworkKind = frameworkKind
        self.cacheBuilds = cacheBuilds
        self.carthageArguments = carthageArguments
        self.podArguments = podArguments
        self.swiftBuildArguments = swiftBuildArguments
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
