//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension SPMManager: HasUpdateCommand, HasBuildCommand {

    struct Options: ParsableArguments, HasDepofileExtension {

        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                completion: .list(DataCoder.Kind.allFlagsHelp))
        var depofileExtension: DataCoder.Kind = .defaultValue

        @Option(completion: .file())
        var swiftCommandPath: String = AppConfiguration.Path.Absolute.swiftCommandPath
    }

    convenience init(depofile: Depofile, options: Options) {
        self.init(depofile: depofile, swiftCommandPath: options.swiftCommandPath)
    }
}
