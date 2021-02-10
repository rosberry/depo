//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class AllPackagesManager: ProgressObservable, HasAllCommands {

    public typealias Package = Depofile
    public typealias BuildResult = PackageOutput<Package>
    typealias PackageManager<SourceManager: CanOutputPackages> = GitCachablePackageManager<ConditionalPackageManager<SourceManager>>
      where SourceManager.Package: GitIdentifiablePackage

    public enum State {
        case podManager(PodManager.State)
        case carthageManager(CarthageManager.State)
        case spmManager(SPMManager.State)
    }

    public let outputPath: String = ""

    private let platform: Platform
    private var podManager: PackageManager<PodManager> {
        let manager = PodManager(podCommandPath: podCommandPath,
                                 frameworkKind: frameworkKind,
                                 podArguments: podArguments).subscribe { [weak self] state in
            self?.observer?(.podManager(state))
        }
        return packageManager(manager: manager, keyPath: \.isEmpty.not)
    }
    private var carthageManager: PackageManager<CarthageManager> {
        let manager = CarthageManager(platform: platform,
                                      carthageCommandPath: carthageCommandPath,
                                      cacheBuilds: cacheBuilds,
                                      carthageArguments: carthageArguments).subscribe { [weak self] state in
            self?.observer?(.carthageManager(state))
        }
        return packageManager(manager: manager, keyPath: \.isEmpty.not)
    }
    private var spmManager: PackageManager<SPMManager> {
        let manager = SPMManager(swiftCommandPath: swiftCommandPath,
                                 frameworkKind: frameworkKind,
                                 swiftBuildArguments: swiftBuildArguments).subscribe { [weak self] state in
            self?.observer?(.spmManager(state))
        }
        return packageManager(manager: manager, keyPath: \.isEmpty.not)
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
    private let xcodebuildVersion: XcodeBuild.Version? = {
        try? XcodeBuild(shell: .init()).version()
    }()

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

    public func update(packages: [Package]) throws -> [BuildResult] {
        let depofile = try packages.single()
        let podUpdate: () throws -> Void      = { try self.podManager.update(packages: depofile.pods) }
        let carthageUpdate: () throws -> Void = { try self.carthageManager.update(packages: depofile.carts) }
        let spmUpdate: () throws -> Void      = { try self.spmManager.update(packages: depofile.swiftPackages) }
        try CommandRunner.runIndependently {
            podUpdate
            carthageUpdate
            spmUpdate
        }
        return []
    }

    public func install(packages: [Package]) throws -> [BuildResult] {
        let depofile = try packages.single()
        let podInstall: () throws -> Void      = { try self.podManager.install(packages: depofile.pods) }
        let carthageInstall: () throws -> Void = { try self.carthageManager.install(packages: depofile.carts) }
        let spmUpdate: () throws -> Void       = { try self.spmManager.update(packages: depofile.swiftPackages) }
        try CommandRunner.runIndependently {
            podInstall
            carthageInstall
            spmUpdate
        }
        return []
    }

    public func build(packages: [Package]) throws -> [BuildResult] {
        let depofile = try packages.single()
        let podBuild: () throws -> Void      = { try self.podManager.build(packages: depofile.pods) }
        let carthageBuild: () throws -> Void = { try self.carthageManager.build(packages: depofile.carts) }
        let spmBuild: () throws -> Void      = { try self.spmManager.build(packages: depofile.swiftPackages) }
        try CommandRunner.runIndependently {
            podBuild
            carthageBuild
            spmBuild
        }
        return []
    }

    private func packageManager<Manager: CanOutputPackages>(
      manager: Manager,
      keyPath: KeyPath<[Manager.Package], Bool>
    ) -> PackageManager<Manager>
      where Manager.Package: GitIdentifiablePackage {
        let conditionalPM = ConditionalPackageManager(wrappedValue: manager, keyPath: keyPath)
        let gitCachablePM = GitCachablePackageManager(wrappedValue: conditionalPM,
                                                      xcodebuildVersion: xcodebuildVersion)
        return gitCachablePM
    }
}
