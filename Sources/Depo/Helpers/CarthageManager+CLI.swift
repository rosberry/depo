//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension CarthageManager: HasPackagesInit {

    public typealias Packages = [CarthageItem]

    public struct Options: HasDepofileExtension, ParsableArguments {
        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                completion: .list(DataCoder.Kind.allFlagsHelp))
        public var depofileExtension: DataCoder.Kind = .defaultValue

        @Option(name: [.customLong("platform"), .customShort(Character("p"))],
                completion: .list(Platform.allFlagsHelp))
        public var platform: Platform = .defaultValue

        @Option(completion: .file())
        public var carthageCommandPath: String = AppConfiguration.Path.Absolute.carthageCommandPath

        @Flag()
        public var cacheBuilds: Bool = false

        @Option(name: [.customLong("carthage-args"), .customShort(Character("c"))])
        public var carthageArguments: String?

        public init() {}
    }

    public convenience init(packages: Packages, options: Options) {
        self.init(carthageItems: packages,
                  platform: options.platform,
                  carthageCommandPath: options.carthageCommandPath,
                  cacheBuilds: options.cacheBuilds,
                  carthageArguments: options.carthageArguments)
    }
}
