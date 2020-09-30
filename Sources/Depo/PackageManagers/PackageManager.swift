//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

typealias PackageManager = HasInstallCommand & HasUpdateCommand & HasBuildCommand & HasDepofileInit

protocol HasDepofileInit {
    init(depofile: Depofile)
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
