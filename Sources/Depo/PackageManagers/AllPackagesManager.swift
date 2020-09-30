//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class AllPackagesManager: PackageManager {

    private let depofile: Depofile

    init(depofile: Depofile) {
        self.depofile = depofile
    }

    func update() throws {
        try CompositeError {
            PodManager(depofile: depofile).update
            CarthageManager(depofile: depofile).update
            SPMManager(depofile: depofile).update
        }
    }

    func install() throws {
        try CompositeError {
            PodManager(depofile: depofile).install
            CarthageManager(depofile: depofile).install
            SPMManager(depofile: depofile).update
        }
    }

    func build() throws {
        try CompositeError {
            PodManager(depofile: depofile).build
            CarthageManager(depofile: depofile).build
            SPMManager(depofile: depofile).build
        }
    }
}
