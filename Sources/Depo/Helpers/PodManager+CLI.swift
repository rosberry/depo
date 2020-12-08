//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension PodManager: CLIPackageManager {

    struct Options: ParsableArguments, HasDepofileExtension {

        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                completion: .list(DataCoder.Kind.allFlagsHelp))
        var depofileExtension: DataCoder.Kind = .defaultValue

        @Option(completion: .file())
        var podCommandPath: String = AppConfiguration.Path.Absolute.podCommandPath
    }

    convenience init(depofile: Depofile, options: Options) {
        self.init(depofile: depofile, podCommandPath: options.podCommandPath)
    }
}
