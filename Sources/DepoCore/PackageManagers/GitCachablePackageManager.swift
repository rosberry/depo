//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import PathKit

public struct GitCachablePackageManager<PM: PackageManager>: PackageManager where PM.Package: GitIdentifiablePackage {

    public typealias Package = PM.Package
    public typealias BuildResult = PackageOutput<Package>
    private typealias SortedPackages = (toBuild: [Package], fromCache: [Package])

    public static var outputPath: String {
        PM.outputPath
    }
    public static var keyPath: KeyPath<Depofile, [PM.Package]> {
        PM.keyPath
    }

    public let packages: [Package]
    public let packageManagerFactory: ([Package]) -> PM
    public let xcodeVersion: XcodeBuild.Version?
    public let cacher: GitCacher

    public init(packages: [Package],
                packageManagerFactory: @escaping ([Package]) -> PM,
                xcodebuildVersion: XcodeBuild.Version?,
                cacheURL: URL) {
        self.packages = packages
        self.packageManagerFactory = packageManagerFactory
        self.xcodeVersion = xcodebuildVersion
        cacher = .init(gitRepoURL: cacheURL)
    }

    private func checkCacheAndRun(action: (PM) throws -> [BuildResult]) throws -> [BuildResult] {
        let (toBuild, fromCache) = try sort(packages: packages, cachedPackageIDs: try cacher.packageIDS())
        let cachedPackageURLs = try fromCache.map { package -> URL in
            let id = package.packageID(xcodeVersion: xcodeVersion)
            return try cacher.get(packageID: id)
        }
        try process(urlsOfCachedBuilds: cachedPackageURLs)
        guard !toBuild.isEmpty else {
            return []
        }
        let outputs = try action(packageManagerFactory(toBuild))
        try cache(builds: outputs)
        return outputs
    }

    private func cache(builds: [BuildResult]) throws {
        guard !builds.isEmpty else {
            return
        }
        let (successBuilds, _) = separate(builds)
        for (package, paths) in successBuilds {
            let urls = try paths.map { path in
                try URL.throwingInit(string: path)
            }
            try cacher.save(buildURLs: urls, packageID: package.packageID(xcodeVersion: xcodeVersion))
        }
    }

    private func sort(packages: [Package], cachedPackageIDs: [GitCacher.PackageID]) throws -> SortedPackages {
        packages.reduce(([Package](), [Package]())) { result, package in
            let (toBuild, fromCache) = result
            if cachedPackageIDs.contains(with: package.packageID(xcodeVersion: xcodeVersion), at: \.self) {
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
        let outputPath = try createIfNeeded(path: Path(Self.outputPath))
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

    public func update() throws -> PackagesOutput<PM.Package> {
        try checkCacheAndRun { packageManager in
            try packageManager.update()
        }
    }

    public func install() throws -> PackagesOutput<PM.Package> {
        try checkCacheAndRun { packageManager in
            try packageManager.install()
        }
    }

    public func build() throws -> PackagesOutput<PM.Package> {
        try checkCacheAndRun { packageManager in
            try packageManager.build()
        }
    }
}
