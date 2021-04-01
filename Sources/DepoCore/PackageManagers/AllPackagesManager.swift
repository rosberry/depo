//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class AllPackagesManager: ProgressObservable, PackageManager {
    public static var keyPath: KeyPath<Depofile, [Depofile]> {
        \.array
    }

    public typealias Package = Depofile
    public typealias BuildResult = PackageOutput<Package>

    public enum State {
        case podManager(PodManager.State)
        case carthageManager(CarthageManager.State)
        case spmManager(SPMManager.State)
    }

    static public let outputPath: String = "."

    public var packages: [Depofile] {
        [depofile]
    }
    private let depofile: Depofile
    private let platform: Platform
    private let wrapper: PackageManagerWrapper = .init()

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

    public func update() throws -> [BuildResult] {
        let podUpdate: () throws -> Void = { _ = try self.podManager().update() }
        let carthageUpdate: () throws -> Void = { _ = try self.carthageManager().update() }
        let spmUpdate: () throws -> Void = { _ = try self.spmManager().update() }
        try CommandRunner.runIndependently {
            podUpdate
            carthageUpdate
            spmUpdate
        }
        return []
    }

    public func install() throws -> [BuildResult] {
        let podInstall: () throws -> Void = { _ = try self.podManager().install() }
        let carthageInstall: () throws -> Void = { _ = try self.carthageManager().install() }
        let spmUpdate: () throws -> Void = { _ = try self.spmManager().install() }
        try CommandRunner.runIndependently {
            podInstall
            carthageInstall
            spmUpdate
        }
        return []
    }

    public func build() throws -> [BuildResult] {
        let podBuild: () throws -> Void = { _ = try self.podManager().build() }
        let carthageBuild: () throws -> Void = { _ = try self.carthageManager().build() }
        let spmBuild: () throws -> Void = { _ = try self.spmManager().build() }
        try CommandRunner.runIndependently {
            podBuild
            carthageBuild
            spmBuild
        }
        return []
    }
}

extension AllPackagesManager {
    private func podManager() throws -> AnyPackageManager<Pod> {
        try wrapper.wrap(packages: depofile.pods,
                         cacheBuilds: cacheBuilds,
                         cacheURL: depofile.cacheURL) { [unowned self] packages in
            PodManager(packages: packages,
                       podCommandPath: self.podCommandPath,
                       frameworkKind: self.frameworkKind,
                       podArguments: self.podArguments).subscribe { [weak self] state in
                self?.observer?(.podManager(state))
            }
        }
    }

    private func carthageManager() throws -> AnyPackageManager<CarthageItem> {
        try wrapper.wrap(packages: depofile.carts,
                         cacheBuilds: cacheBuilds,
                         cacheURL: depofile.cacheURL) { [unowned self] packages in
            CarthageManager(packages: packages,
                            platform: platform,
                            carthageCommandPath: carthageCommandPath,
                            cacheBuilds: cacheBuilds,
                            carthageArguments: carthageArguments).subscribe { [weak self] state in
                self?.observer?(.carthageManager(state))
            }
        }
    }

    private func spmManager() throws -> AnyPackageManager<SwiftPackage> {
        try wrapper.wrap(packages: depofile.swiftPackages,
                         cacheBuilds: cacheBuilds,
                         cacheURL: depofile.cacheURL) { [unowned self] packages in
            SPMManager(packages: packages,
                       swiftCommandPath: swiftCommandPath,
                       frameworkKind: frameworkKind,
                       swiftBuildArguments: swiftBuildArguments).subscribe { [weak self] state in
                self?.observer?(.spmManager(state))
            }
        }
    }
}
