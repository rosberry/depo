//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public typealias CLIPackageManager = HasAllCommands & HasPackagesInit
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

public protocol HasPackagesInit {
    associatedtype Options: HasDepofileExtension
    associatedtype Packages

    init(packages: Packages, options: Options)
}

public protocol HasUpdateCommand {
    func update() throws
}

public protocol HasInstallCommand {
    func install() throws
}

public protocol HasBuildCommand {
    func build() throws
}
