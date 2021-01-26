//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension SPMManager: HasDepofileInit {

    public struct Options: ParsableArguments, HasDepofileExtension {

        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                completion: .list(DataCoder.Kind.allFlagsHelp))
        public var depofileExtension: DataCoder.Kind = .defaultValue

        @Option(completion: .file())
        public var swiftCommandPath: String = AppConfiguration.Path.Absolute.swiftCommandPath

        @Flag()
        public var frameworkKind: MergePackage.FrameworkKind = .fatFramework

        @Flag()
        public var cacheBuilds: Bool = false

        @Option(name: [.customLong("swift-build-args"), .customShort(Character("s"))])
        public var swiftBuildArguments: String?

        public init() {}
    }

    public convenience init(depofile: Depofile, options: Options) {
        self.init(depofile: depofile,
                  swiftCommandPath: options.swiftCommandPath,
                  frameworkKind: options.frameworkKind,
                  cacheBuilds: options.cacheBuilds,
                  swiftBuildArguments: options.swiftBuildArguments)
    }
}
