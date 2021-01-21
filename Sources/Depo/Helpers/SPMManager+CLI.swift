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

        @Flag()
        var frameworkKind: MergePackage.FrameworkKind = .fatFramework

        @Flag()
        var cacheBuilds: Bool = false
        
        @Option(name: [.customLong("swift-build-args"), .customShort(Character("s"))])
        var swiftBuildArguments: String?
        
    }

    convenience init(depofile: Depofile, options: Options) {
        self.init(depofile: depofile,
                  swiftCommandPath: options.swiftCommandPath,
                  frameworkKind: options.frameworkKind,
                  cacheBuilds: options.cacheBuilds,
                  swiftBuildArguments: options.swiftBuildArguments)
    }
}
