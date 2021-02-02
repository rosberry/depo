//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class AllPackagesManager: ProgressObservable, HasAllCommands {

    public typealias Packages = Depofile

    public enum State {
        case podManager(PodManager.State)
        case carthageManager(CarthageManager.State)
        case spmManager(SPMManager.State)
    }

    public let outputPath: String = ""

    private let platform: Platform
    private var podManager: ConditionalPackageManager<PodManager, PodManager.Packages> {
        let manager = PodManager(podCommandPath: podCommandPath,
                                 frameworkKind: frameworkKind,
                                 cacheBuilds: cacheBuilds,
                                 podArguments: podArguments).subscribe { [weak self] state in
            self?.observer?(.podManager(state))
        }
        return conditional(manager: manager, keyPath: \PodManager.Packages.isEmpty.not)
    }
    private var carthageManager: ConditionalPackageManager<CarthageManager, CarthageManager.Packages> {
        let manager = CarthageManager(platform: platform,
                                      carthageCommandPath: carthageCommandPath,
                                      cacheBuilds: cacheBuilds,
                                      carthageArguments: carthageArguments).subscribe { [weak self] state in
            self?.observer?(.carthageManager(state))
        }
        return conditional(manager: manager, keyPath: \CarthageManager.Packages.isEmpty.not)
    }
    private var spmManager: ConditionalPackageManager<SPMManager, SPMManager.Packages> {
        let manager = SPMManager(swiftCommandPath: swiftCommandPath,
                                 frameworkKind: frameworkKind,
                                 cacheBuilds: cacheBuilds,
                                 swiftBuildArguments: swiftBuildArguments).subscribe { [weak self] state in
            self?.observer?(.spmManager(state))
        }
        return conditional(manager: manager, keyPath: \SPMManager.Packages.isEmpty.not)
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

    public init(platform: Platform,
                podCommandPath: String,
                carthageCommandPath: String,
                swiftCommandPath: String,
                frameworkKind: MergePackage.FrameworkKind,
                cacheBuilds: Bool,
                carthageArguments: String?,
                podArguments: String?,
                swiftBuildArguments: String?) {
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

    public func update(packages: Depofile) throws {
        let podUpdate: () throws -> Void      = { try self.podManager.update(packages: packages.pods) }
        let carthageUpdate: () throws -> Void = { try self.carthageManager.update(packages: packages.carts) }
        let spmUpdate: () throws -> Void      = { try self.spmManager.update(packages: packages.swiftPackages) }
        try CommandRunner.runIndependently {
            podUpdate
            carthageUpdate
            spmUpdate
        }
    }

    public func install(packages: Depofile) throws {
        let podInstall: () throws -> Void      = { try self.podManager.install(packages: packages.pods) }
        let carthageInstall: () throws -> Void = { try self.carthageManager.install(packages: packages.carts) }
        let spmUpdate: () throws -> Void       = { try self.spmManager.update(packages: packages.swiftPackages) }
        try CommandRunner.runIndependently {
            podInstall
            carthageInstall
            spmUpdate
        }
    }

    public func build(packages: Depofile) throws {
        let podBuild: () throws -> Void      = { try self.podManager.build(packages: packages.pods) }
        let carthageBuild: () throws -> Void = { try self.carthageManager.build(packages: packages.carts) }
        let spmBuild: () throws -> Void      = { try self.spmManager.build(packages: packages.swiftPackages) }
        try CommandRunner.runIndependently {
            podBuild
            carthageBuild
            spmBuild
        }
    }

    private func conditional<Manager, Root>(
      manager: Manager,
      keyPath: KeyPath<Root, Bool>
    ) -> ConditionalPackageManager<Manager, Root> {
        .init(wrappedValue: manager, keyPath: keyPath)
    }
}
