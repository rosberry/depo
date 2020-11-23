//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension PodManager: CLIPackageManager {

    typealias Options = DefaultOptions

    convenience init(depofile: Depofile, options: DefaultOptions) {
        self.init(depofile: depofile)
    }
}
