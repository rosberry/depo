//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public typealias PackagesOutput<Package> = [PackageOutput<Package>]
public typealias PackageOutput<Package> = Result<SuccessBuild<Package>, FailureBuild<Package>>
public typealias SuccessBuild<Package> = (Package, [String])
public typealias FailureBuild<Package> = FailureWrapper<Package, Swift.Error>

public protocol PackageManager {
    associatedtype Package

    static var keyPath: KeyPath<Depofile, [Package]> { get }
    var packages: [Package] { get }
    static var outputPath: String { get }

    func update() throws -> PackagesOutput<Package>
    func install() throws -> PackagesOutput<Package>
    func build() throws -> PackagesOutput<Package>
}

public extension PackageManager {
    func eraseToAny() -> AnyPackageManager<Package> {
        .init(packageManager: self)
    }
}

public protocol HasCacheBuildsFlag {
    var cacheBuilds: Bool { get }
}
