//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public typealias CLIPackageManager = HasAllCommands & HasDepofileInit
public typealias HasAllCommands = HasInstallCommand & HasUpdateCommand & HasBuildCommand

public protocol HasDepofileExtension {
    var depofileExtension: DataCoder.Kind {
        get
    }
}

public protocol HasDepofileInit {
    associatedtype Options: HasDepofileExtension

    init(depofile: Depofile, options: Options)
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
