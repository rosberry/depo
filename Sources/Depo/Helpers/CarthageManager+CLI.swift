//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension CarthageManager: CLIPackageManager {

    struct Options: HasDepofileExtension, ParsableArguments {
        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                help: "\(DataCoder.Kind.allFlagsHelp)")
        var depofileExtension: DataCoder.Kind = .defaultValue

        @Option(name: [.customLong("platform"), .customShort(Character("p"))],
                help: "\(Platform.allFlagsHelp)")
        var platform: Platform = .defaultValue
    }

    convenience init(depofile: Depofile, options: Options) {
        self.init(depofile: depofile, platform: options.platform)
    }
}
