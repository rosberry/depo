//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

typealias PackageManagerCommand = InstallPackageManagerCommand & UpdatePackageManagerCommand

protocol UpdatePackageManagerCommand {
    init(depofile: Depofile)

    func update() throws
}

protocol InstallPackageManagerCommand {
    init(depofile: Depofile)

    func install() throws
}
