//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

typealias PackageManager = HasInstallCommand & HasUpdateCommand & HasBuildCommand & HasDepofileInit

protocol HasDepofileExtension {
    var depofileExtension: DataDecoder.Kind {
        get
    }
}

protocol HasDepofileInit {
    associatedtype Options: ParsableArguments & HasDepofileExtension

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
