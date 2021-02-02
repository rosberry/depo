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

public protocol HasUpdateCommand {
    associatedtype Packages

    func update(packages: Packages) throws
}

public protocol HasInstallCommand {
    associatedtype Packages

    func install(packages: Packages) throws
}

public protocol HasBuildCommand {
    associatedtype Packages

    func build(packages: Packages) throws
}
