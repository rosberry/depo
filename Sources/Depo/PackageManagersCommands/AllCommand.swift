//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class AllCommand: PackageManagerCommand {

    private let depofile: Depofile

    init(depofile: Depofile) {
        self.depofile = depofile
    }

    func update() throws {
        try CompositeError {
            PodCommand(depofile: depofile).update
            CarthageCommand(depofile: depofile).update
            SwiftPackageCommand(depofile: depofile).update
        }
    }

    func install() throws {
        try CompositeError {
            PodCommand(depofile: depofile).install
            CarthageCommand(depofile: depofile).install
            SwiftPackageCommand(depofile: depofile).update
        }
    }
}
