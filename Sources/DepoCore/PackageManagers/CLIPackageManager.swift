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

    var outputPath: String { get }

    func update() throws -> PackagesOutput<Package>
    func install() throws -> PackagesOutput<Package>
    func build() throws -> PackagesOutput<Package>
}

public protocol HasDepofileExtension {
    var depofileExtension: DataCoder.Kind { get }
    var cacheBuilds: Bool { get }
}

public protocol HasCacheBuildsFlag {
    var cacheBuilds: Bool { get }
}

public protocol HasOptionsInit {
    associatedtype Options: HasDepofileExtension

    init(options: Options)
}
