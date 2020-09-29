//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class Update: ParsableCommand {

    @OptionGroup()
    private var options: Options

    func run() throws {
        let depofile = try Depofile(decoder: options.depoFileType.decoder)
        try CompositeError {
            PodCommand(pods: depofile.pods).update
            CarthageCommand(carthageItems: depofile.carts).update
        }
    }
}
