//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore

struct DefaultOptions: ParsableArguments, HasDepofileExtension {

    @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
            help: "\(DataCoder.Kind.allFlagsHelp)")
    var depofileExtension: DataCoder.Kind = .defaultValue
}
