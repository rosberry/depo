//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import PathKit

@propertyWrapper
public struct GitCachablePackageManager<PackageManager: CanOutputPackages>: CanOutputPackages where PackageManager.Package: GitIdentifiablePackage {

    public typealias Package = PackageManager.Package
    public typealias BuildResult = PackageOutput<Package>
    private typealias SortedPackages = (toBuild: [Package], fromCache: [Package])

    public var outputPath: String {
        wrappedValue.outputPath
    }

    public let wrappedValue: PackageManager
    public let cacher: GitCacher = .init(gitRepoURL: URL(string: "git@github.com:zhvrnkov/frameworks-store.git")!)

    public init(wrappedValue: PackageManager) {
        self.wrappedValue = wrappedValue
    }

    private func checkCacheAndRun<T>(action: ([Package]) throws -> T, packages: [Package]) throws -> T {
        let (toBuild, fromCache) = try sort(packages: packages, cachedPackageIDs: try cacher.packageIDS())
        let cachedPackageURLs = try fromCache.map { package in
            try cacher.get(packageID: package.packageID)
        }
        try process(urlsOfCachedBuilds: cachedPackageURLs)
        return try action(toBuild)
    }

    private func sort(packages: [Package], cachedPackageIDs: [GitCacher.PackageID]) throws -> SortedPackages {
        packages.reduce(([Package](), [Package]())) { result, package in
            let (toBuild, fromCache) = result
            if cachedPackageIDs.contains(with: package.packageID, at: \.self) {
                return (toBuild, fromCache + [package])
            }
            else {
                return (toBuild + [package], fromCache)
            }
        }
    }

    private func createIfNeeded(path: Path) throws -> Path {
        if !path.exists {
            try path.mkpath()
        }
        return path
    }

    private func process(urlsOfCachedBuilds urls: [URL]) throws {
        let outputPath = try createIfNeeded(path: Path(self.outputPath))
        for url in urls {
            let path = Path(url.path)
            try moveContents(of: path, to: outputPath)
            try path.delete()
        }
    }

    private func moveContents(of path: Path, to outputPath: Path) throws {
        let content = path.glob("*")
        for item in content {
            let newPath = outputPath + item.lastComponent
            try? newPath.delete()
            try item.move(newPath)
        }
    }
}

extension GitCachablePackageManager: HasUpdateCommand where PackageManager: HasUpdateCommand {
    public func update(packages: [Package]) throws -> [BuildResult] {
        try checkCacheAndRun(action: wrappedValue.update, packages: packages)
    }
}

extension GitCachablePackageManager: HasInstallCommand where PackageManager: HasInstallCommand {
    public func install(packages: [Package]) throws -> [BuildResult] {
        try checkCacheAndRun(action: wrappedValue.install, packages: packages)
    }
}

extension GitCachablePackageManager: HasBuildCommand where PackageManager: HasBuildCommand {
    public func build(packages: [Package]) throws -> [BuildResult] {
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
