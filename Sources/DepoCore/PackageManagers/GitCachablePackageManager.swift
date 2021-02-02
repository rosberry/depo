//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import Files

@propertyWrapper
struct GitCachablePackageManager<PackageManager: CanOutputPackages>: CanOutputPackages where PackageManager.Packages == [GitIdentifiablePackage] {

    typealias Packages = PackageManager.Packages

    var outputPath: String {
        wrappedValue.outputPath
    }

    let wrappedValue: PackageManager
    let cacher: GitCacher = .init(gitRepoURL: URL(string: "git@github.com:zhvrnkov/frameworks-store.git")!)

    private func checkCacheAndRun(action: (Packages) throws -> Void, packages: Packages) throws {
        let cachedPackages = try cacher.packageIDS()
        let (toBuild, fromCache) = packages.reduce(([GitIdentifiablePackage](), [GitIdentifiablePackage]())) { result, package in
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
            try Folder(path: url.absoluteString).copyContents(to: outputFolder)
        }
        try action(toBuild)
    }
}

extension GitCachablePackageManager: HasUpdateCommand where PackageManager: HasUpdateCommand {
    func update(packages: Packages) throws {
        try checkCacheAndRun(action: wrappedValue.update, packages: packages)
    }
}

extension GitCachablePackageManager: HasInstallCommand where PackageManager: HasInstallCommand {
    func install(packages: Packages) throws {
        try checkCacheAndRun(action: wrappedValue.install, packages: packages)
    }
}

extension GitCachablePackageManager: HasBuildCommand where PackageManager: HasBuildCommand {
    func build(packages: Packages) throws {
        try checkCacheAndRun(action: wrappedValue.build, packages: packages)
    }
}
