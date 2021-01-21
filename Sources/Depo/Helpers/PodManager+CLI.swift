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

        @Flag()
        var frameworkKind: MergePackage.FrameworkKind = .fatFramework

        @Flag()
        var cacheBuilds: Bool = false
        
        @Option(name: [.customLong("pod-args")])
        var podArguments: String?
    }

    convenience init(depofile: Depofile, options: Options) {
        self.init(depofile: depofile,
                  podCommandPath: options.podCommandPath,
                  frameworkKind: options.frameworkKind,
                  cacheBuilds: options.cacheBuilds,
                  podArguments: options.podArguments)
    }
}
