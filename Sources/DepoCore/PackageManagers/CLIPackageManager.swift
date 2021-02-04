//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public typealias CLIPackageManager = HasAllCommands & HasOptionsInit
public typealias HasAllCommands = HasInstallCommand & HasUpdateCommand & HasBuildCommand

public protocol HasDepofileExtension {
    var depofileExtension: DataCoder.Kind { get }
}

public protocol HasCacheBuildsFlag {
    var cacheBuilds: Bool { get }
}

public protocol HasDepofileKeyPath {
    associatedtype ValueType

    static var depofileKeyPath: KeyPath<Depofile, ValueType> { get }
}

public protocol HasOptionsInit {
    associatedtype Options: HasDepofileExtension

    init(options: Options)
}

public protocol CanOutputPackages {

    associatedtype Package

    var outputPath: String { get }
}

public protocol HasUpdateCommand: CanOutputPackages {
    func update(packages: [Package]) throws
}

public protocol HasInstallCommand: CanOutputPackages {
    func install(packages: [Package]) throws
}

public protocol HasBuildCommand: CanOutputPackages {
    func build(packages: [Package]) throws
}
