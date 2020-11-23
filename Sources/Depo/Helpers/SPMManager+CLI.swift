//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension SPMManager: HasUpdateCommand, HasBuildCommand {

    typealias Options = DefaultOptions

    convenience init(depofile: Depofile, options: DefaultOptions) {
        self.init(depofile: depofile)
    }
}
