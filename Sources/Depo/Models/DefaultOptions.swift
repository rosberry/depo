//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

struct DefaultOptions: ParsableArguments, HasDepofileExtension {

    @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
            help: "\(DataDecoder.Kind.allFlagsHelp)")
    var depofileExtension: DataDecoder.Kind = .defaultValue
}
