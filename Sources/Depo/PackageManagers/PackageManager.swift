//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

typealias PackageManager = HasInstallCommand & HasUpdateCommand & HasDepofileInit

protocol HasUpdateCommand: HasDepofileInit {
    func update() throws
}

protocol HasInstallCommand: HasDepofileInit {
    func install() throws
}

protocol HasDepofileInit {
    init(depofile: Depofile)
}
