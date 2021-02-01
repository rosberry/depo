//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension AllPackagesManager: HasPackagesInit {

    public typealias Packages = Depofile

    public struct Options: HasDepofileExtension, ParsableArguments {
        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                completion: .list(DataCoder.Kind.allFlagsHelp))
        public var depofileExtension: DataCoder.Kind = .defaultValue

        @Option(name: [.customLong("platform"), .customShort(Character("p"))],
                completion: .list(Platform.allFlagsHelp))
        public var platform: Platform = .defaultValue

        @Option(completion: .file())
        public var podCommandPath: String = AppConfiguration.Path.Absolute.podCommandPath

        @Option(completion: .file())
        public var carthageCommandPath: String = AppConfiguration.Path.Absolute.carthageCommandPath

        @Option(completion: .file())
        public var swiftCommandPath: String = AppConfiguration.Path.Absolute.swiftCommandPath

        @Flag()
        public var frameworkKind: MergePackage.FrameworkKind = .fatFramework

        @Flag()
        public var cacheBuilds: Bool = false

        @Option(name: [.customLong("carthage-args"), .customShort(Character("c"))])
        public var carthageArguments: String?

        @Option(name: [.customLong("pod-args")])
        public var podArguments: String?

        @Option(name: [.customLong("swift-build-args"), .customShort(Character("s"))])
        public var swiftBuildArguments: String?

        public init() {}
    }

    public convenience init(packages: Packages, options: Options) {
        self.init(depofile: packages,
                  platform: options.platform,
                  podCommandPath: options.podCommandPath,
                  carthageCommandPath: options.carthageCommandPath,
                  swiftCommandPath: options.swiftCommandPath,
                  frameworkKind: options.frameworkKind,
                  cacheBuilds: options.cacheBuilds,
                  carthageArguments: options.carthageArguments,
                  podArguments: options.podArguments,
                  swiftBuildArguments: options.swiftBuildArguments)
    }
}
