//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

extension SPMManager: HasOptionsInit {

    public struct Options: ParsableArguments, HasDepofileExtension {

        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                completion: .list(DataCoder.Kind.allFlagsHelp))
        public var depofileExtension: DataCoder.Kind = .defaultValue

        @Option(completion: .file())
        public var swiftCommandPath: String = AppConfiguration.Path.Absolute.swiftCommandPath

        @Flag()
        public var buildKind: SPMManager.BuildKind = .staticLib

        @Flag()
        public var cacheBuilds: Bool = false

        @Option(name: [.customLong("swift-build-args"), .customShort(Character("s"))])
        public var swiftBuildArguments: String?

        public init() {
        }
    }

    public convenience init(depofile: Depofile, options: Options) {
        self.init(packages: depofile.swiftPackages,
                  swiftCommandPath: options.swiftCommandPath,
                  buildKind: options.buildKind,
                  swiftBuildArguments: options.swiftBuildArguments)
    }
}

extension SPMManager.BuildKind: CustomStringConvertible, EnumerableFlag {
    public var description: String {
        switch self {
        case .fat:
            return "fat-framework"
        case .xcframework:
            return "xcframework"
        case .staticLib:
            return "static-lib"
        }
    }
}
