//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class AllPackagesManager: ProgressObservable, HasAllCommands {

    public enum State {
        case podManager(PodManager.State)
        case carthageManager(CarthageManager.State)
        case spmManager(SPMManager.State)
    }

    private let depofile: Depofile
    private let platform: Platform
    private var podManager: ConditionalPackageManager<PodManager> {
        let manager = PodManager(pods: depofile.pods,
                                 podCommandPath: podCommandPath,
                                 frameworkKind: frameworkKind,
                                 cacheBuilds: cacheBuilds,
                                 podArguments: podArguments).subscribe { [weak self] state in
            self?.observer?(.podManager(state))
        }
        return conditional(manager: manager, keyPath: \.pods.isEmpty.not)
    }
    private var carthageManager: ConditionalPackageManager<CarthageManager> {
        let manager = CarthageManager(carthageItems: depofile.carts,
                                      platform: platform,
                                      carthageCommandPath: carthageCommandPath,
                                      cacheBuilds: cacheBuilds,
                                      carthageArguments: carthageArguments).subscribe { [weak self] state in
            self?.observer?(.carthageManager(state))
        }
        return conditional(manager: manager, keyPath: \.carts.isEmpty.not)
    }
    private var spmManager: ConditionalPackageManager<SPMManager> {
        let manager = SPMManager(swiftPackages: depofile.swiftPackages,
                                 swiftCommandPath: swiftCommandPath,
                                 frameworkKind: frameworkKind,
                                 cacheBuilds: cacheBuilds,
                                 swiftBuildArguments: swiftBuildArguments).subscribe { [weak self] state in
            self?.observer?(.spmManager(state))
        }
        return conditional(manager: manager, keyPath: \.swiftPackages.isEmpty.not)
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

    private func conditional<Manager>(manager: Manager, keyPath: KeyPath<Depofile, Bool>) -> ConditionalPackageManager<Manager> {
        .init(wrappedValue: manager, root: depofile, keyPath: keyPath)
    }
}
