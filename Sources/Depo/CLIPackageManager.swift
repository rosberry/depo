//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

typealias CLIPackageManager = HasInstallCommand & HasUpdateCommand & HasBuildCommand & HasDepofileInit

protocol HasDepofileExtension {
    var depofileExtension: DataCoder.Kind {
        get
    }
}

protocol HasDepofileInit {
    associatedtype Options: HasDepofileExtension

    init(depofile: Depofile, options: Options)
}

protocol HasUpdateCommand: HasDepofileInit {
    func update() throws
}

protocol HasInstallCommand: HasDepofileInit {
    func install() throws
}

protocol HasBuildCommand: HasDepofileInit {
    func build() throws
}
