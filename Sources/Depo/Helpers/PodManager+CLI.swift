//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension PodManager: HasDepofileInit {

    public struct Options: ParsableArguments, HasDepofileExtension {

        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                completion: .list(DataCoder.Kind.allFlagsHelp))
        public var depofileExtension: DataCoder.Kind = .defaultValue

        @Option(completion: .file())
        public var podCommandPath: String = AppConfiguration.Path.Absolute.podCommandPath

        @Flag()
        public var frameworkKind: MergePackage.FrameworkKind = .fatFramework

        @Flag()
        public var cacheBuilds: Bool = false

        @Option(name: [.customLong("pod-args")])
        public var podArguments: String?

        public init() {}
    }

    public convenience init(depofile: Depofile, options: Options) {
        self.init(depofile: depofile,
                  podCommandPath: options.podCommandPath,
                  frameworkKind: options.frameworkKind,
                  cacheBuilds: options.cacheBuilds,
                  podArguments: options.podArguments)
    }
}
