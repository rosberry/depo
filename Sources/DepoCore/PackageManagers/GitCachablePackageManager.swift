//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import Files

@propertyWrapper
public struct GitCachablePackageManager<PackageManager: CanOutputPackages, T: GitIdentifiablePackage>: CanOutputPackages where PackageManager.Packages == [T] {

    public typealias Packages = PackageManager.Packages

    public var outputPath: String {
        wrappedValue.outputPath
    }

    public let wrappedValue: PackageManager
    public let cacher: GitCacher = .init(gitRepoURL: URL(string: "git@github.com:zhvrnkov/frameworks-store.git")!)

    public init(wrappedValue: PackageManager) {
        self.wrappedValue = wrappedValue
    }

    private func checkCacheAndRun(action: (Packages) throws -> Void, packages: Packages) throws {
        let cachedPackages = try cacher.packageIDS()
        let (toBuild, fromCache) = packages.reduce((PackageManager.Packages(), PackageManager.Packages())) { result, package in
            let (toBuild, fromCache) = result
            if cachedPackages.contains(with: package.packageID, at: \.self) {
                return (toBuild, fromCache + [package])
            }
            else {
                return (toBuild + [package], fromCache)
            }
        }
        let cachedPackageURLs = try fromCache.map { package in
            try cacher.get(packageID: package.packageID)
        }
        let outputFolder = try Folder(path: outputPath)
        for url in cachedPackageURLs {
            try Folder(path: url.path).copyContents(to: outputFolder)
        }
        try action(toBuild)
    }
}

extension GitCachablePackageManager: HasUpdateCommand where PackageManager: HasUpdateCommand {
    public func update(packages: Packages) throws {
        try checkCacheAndRun(action: wrappedValue.update, packages: packages)
    }
}

extension GitCachablePackageManager: HasInstallCommand where PackageManager: HasInstallCommand {
    public func install(packages: Packages) throws {
        try checkCacheAndRun(action: wrappedValue.install, packages: packages)
    }
}

extension GitCachablePackageManager: HasBuildCommand where PackageManager: HasBuildCommand {
    public func build(packages: Packages) throws {
        try checkCacheAndRun(action: wrappedValue.build, packages: packages)
    }
}

extension GitCachablePackageManager: HasOptionsInit where PackageManager: HasOptionsInit {
    public typealias Options = PackageManager.Options

    public init(options: PackageManager.Options) {
        self.wrappedValue = PackageManager(options: options)
    }
}

extension GitCachablePackageManager: ProgressObservable where PackageManager: ProgressObservable {
    public typealias State = PackageManager.State

    public func subscribe(_ observer: @escaping (PackageManager.State) -> Void) -> Self {
        _ = wrappedValue.subscribe(observer)
        return self
    }
}
