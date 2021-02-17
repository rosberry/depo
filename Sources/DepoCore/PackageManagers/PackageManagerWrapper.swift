//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

public struct PackageManagerWrapper {

    private let xcodebuildVersion: XcodeBuild.Version? = {
        try? XcodeBuild(shell: .init()).version()
    }()

    public init() {}

    public func classAsFunction<Manager: HasAllCommands>(
            manager: Manager,
            keyPath: KeyPath<[Manager.Package], Bool> = \.isEmpty.not,
            cacheBuilds: Bool
    ) -> AnyPackageManager<Manager.Package>
            where Manager.Package: GitIdentifiablePackage {
        let conditionalPM = ConditionalPackageManager(wrappedValue: manager, keyPath: keyPath)
        if cacheBuilds {
            let gitCachablePM = GitCachablePackageManager(wrappedValue: conditionalPM,
                                                          xcodebuildVersion: xcodebuildVersion)
            return .init(outputPath: gitCachablePM.outputPath,
                         buildClosure: gitCachablePM.build,
                         installClosure: gitCachablePM.install,
                         updateClosure: gitCachablePM.update)
        }
        else {
            return .init(outputPath: conditionalPM.outputPath,
                         buildClosure: conditionalPM.build,
                         installClosure: conditionalPM.install,
                         updateClosure: conditionalPM.update)
        }
    }

    public func callAsFunction<Manager: HasBuildCommand & HasUpdateCommand>(
            manager: Manager,
            keyPath: KeyPath<[Manager.Package], Bool> = \.isEmpty.not,
            cacheBuilds: Bool
    ) -> AnyPackageManager<Manager.Package>
            where Manager.Package: GitIdentifiablePackage {
        let conditionalPM = ConditionalPackageManager(wrappedValue: manager, keyPath: keyPath)
        if cacheBuilds {
            let gitCachablePM = GitCachablePackageManager(wrappedValue: conditionalPM,
                                                          xcodebuildVersion: xcodebuildVersion)
            return .init(outputPath: gitCachablePM.outputPath,
                         buildClosure: gitCachablePM.build,
                         installClosure: gitCachablePM.update,
                         updateClosure: gitCachablePM.update)
        }
        else {
            return .init(outputPath: conditionalPM.outputPath,
                         buildClosure: conditionalPM.build,
                         installClosure: conditionalPM.update,
                         updateClosure: conditionalPM.update)
        }
    }

    public func callAsFunction<Manager: HasBuildCommand>(
            manager: Manager,
            keyPath: KeyPath<[Manager.Package], Bool> = \.isEmpty.not,
            cacheBuilds: Bool
    ) -> AnyPackageManager<Manager.Package>
            where Manager.Package: GitIdentifiablePackage {
        let conditionalPM = ConditionalPackageManager(wrappedValue: manager, keyPath: keyPath)
        let empty: ([Manager.Package]) throws -> PackagesOutput<Manager.Package> = emptyClosure()
        if cacheBuilds {
            let gitCachablePM = GitCachablePackageManager(wrappedValue: conditionalPM,
                                                          xcodebuildVersion: xcodebuildVersion)
            return .init(outputPath: gitCachablePM.outputPath,
                         buildClosure: gitCachablePM.build,
                         installClosure: empty,
                         updateClosure: empty)
        }
        else {
            return .init(outputPath: conditionalPM.outputPath,
                         buildClosure: conditionalPM.build,
                         installClosure: empty,
                         updateClosure: empty)
        }
    }

    public func callAsFunction<Manager: HasUpdateCommand>(
            manager: Manager,
            keyPath: KeyPath<[Manager.Package], Bool> = \.isEmpty.not,
            cacheBuilds: Bool
    ) -> AnyPackageManager<Manager.Package>
            where Manager.Package: GitIdentifiablePackage {
        let conditionalPM = ConditionalPackageManager(wrappedValue: manager, keyPath: keyPath)
        let empty: ([Manager.Package]) throws -> PackagesOutput<Manager.Package> = emptyClosure()
        if cacheBuilds {
            let gitCachablePM = GitCachablePackageManager(wrappedValue: conditionalPM,
                                                          xcodebuildVersion: xcodebuildVersion)
            return .init(outputPath: gitCachablePM.outputPath,
                         buildClosure: empty,
                         installClosure: empty,
                         updateClosure: gitCachablePM.update)
        }
        else {
            return .init(outputPath: conditionalPM.outputPath,
                         buildClosure: empty,
                         installClosure: empty,
                         updateClosure: conditionalPM.update)
        }
    }

    public func callAsFunction<Manager: HasInstallCommand>(
            manager: Manager,
            keyPath: KeyPath<[Manager.Package], Bool> = \.isEmpty.not,
            cacheBuilds: Bool
    ) -> AnyPackageManager<Manager.Package>
            where Manager.Package: GitIdentifiablePackage {
        let conditionalPM = ConditionalPackageManager(wrappedValue: manager, keyPath: keyPath)
        let empty: ([Manager.Package]) throws -> PackagesOutput<Manager.Package> = emptyClosure()
        if cacheBuilds {
            let gitCachablePM = GitCachablePackageManager(wrappedValue: conditionalPM,
                                                          xcodebuildVersion: xcodebuildVersion)
            return .init(outputPath: gitCachablePM.outputPath,
                         buildClosure: empty,
                         installClosure: gitCachablePM.install,
                         updateClosure: empty)
        }
        else {
            return .init(outputPath: conditionalPM.outputPath,
                         buildClosure: empty,
                         installClosure: conditionalPM.install,
                         updateClosure: empty)
        }
    }

    private func join<A: HasUpdateCommand, B: HasInstallCommand, C: HasBuildCommand>(
            _ update: A,
            _ install: B,
            _ build: C
    ) -> AnyPackageManager<A.Package> where A.Package == B.Package, A.Package == C.Package {
        .init(outputPath: update.outputPath,
              buildClosure: build.build,
              installClosure: install.install,
              updateClosure: update.update)
    }

    private func emptyClosure<P>() -> ([P]) throws -> PackagesOutput<P> {
        { _ in [] }
    }
}
