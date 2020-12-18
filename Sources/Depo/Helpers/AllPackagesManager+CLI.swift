//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension AllPackagesManager: CLIPackageManager {
    struct Options: HasDepofileExtension, ParsableArguments {
        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                completion: .list(DataCoder.Kind.allFlagsHelp))
        var depofileExtension: DataCoder.Kind = .defaultValue

        @Option(name: [.customLong("platform"), .customShort(Character("p"))],
                completion: .list(Platform.allFlagsHelp))
        var platform: Platform = .defaultValue

        @Option(completion: .file())
        var podCommandPath: String = AppConfiguration.Path.Absolute.podCommandPath

        @Option(completion: .file())
        var carthageCommandPath: String = AppConfiguration.Path.Absolute.carthageCommandPath

        @Option(completion: .file())
        var swiftCommandPath: String = AppConfiguration.Path.Absolute.swiftCommandPath

        @Flag()
        var frameworkKind: MergePackage.FrameworkKind = .fat
    }

    convenience init(depofile: Depofile, options: Options) {
        self.init(depofile: depofile,
                  platform: options.platform,
                  podCommandPath: options.podCommandPath,
                  carthageCommandPath: options.carthageCommandPath,
                  swiftCommandPath: options.swiftCommandPath,
                  frameworkKind: options.frameworkKind)
    }
}
