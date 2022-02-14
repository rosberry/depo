//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import Files
import CartfileParser

public final class CarthageShellCommand: ShellCommand {

    public enum BuildArgument {
        case platform(Platform?)
        case cacheBuilds
        case custom(args: String)
        case ssh
        case xcframeworks

        public var strings: [String] {
            switch self {
            case let .platform(platform):
                return platformArguments(platform: platform)
            case .cacheBuilds:
                return ["--cache-builds"]
            case let .custom(args):
                return args.words
            case .ssh:
                return ["--use-ssh"]
            case .xcframeworks:
                return ["--use-xcframeworks"]
            }
        }

        private func platformArguments(platform: Platform?) -> [String] {
            switch platform {
            case .none:
                return []
            case let .some(platform):
                return ["--platform", platform.rawValue]
            }
        }
    }

    @discardableResult
    public func update(arguments: [BuildArgument]) throws -> Int32 {
        try carthage("update", arguments: arguments)
    }

    @discardableResult
    public func bootstrap(arguments: [BuildArgument]) throws -> Int32 {
        try carthage("bootstrap", arguments: arguments)
    }

    @discardableResult
    public func build(arguments: [BuildArgument]) throws -> Int32 {
        try carthage("build", arguments: arguments)
    }

    public func cartfile(url: URL) throws -> Cartfile {
        cartfile(from: try CartfileParser.Cartfile.from(file: url).get())
    }

    public func cartfile(cartfilePath: String) throws -> Cartfile {
        try cartfile(url: try Folder.current.file(at: cartfilePath).url)
    }

    private func carthage(_ command: String, arguments: [BuildArgument]) throws -> Int32 {
        let argumentsString = (arguments + [.ssh, .xcframeworks]).map(\.strings.spaceJoined).joined(separator: " ")
        return try shell(loud: "\(commandPath) \(command) \(argumentsString)")
    }

    private func cartfile(from actualCartfile: CartfileParser.Cartfile) -> Cartfile {
        .init(items: actualCartfile.dependencies.map { dependency, versionSpecifier -> CarthageItem in
            carthageItem(dependency: dependency, versionSpecifier: versionSpecifier)
        })
    }

    private func carthageItem(dependency: CartfileParser.Dependency, versionSpecifier: CartfileParser.VersionSpecifier) -> CarthageItem {
        .init(kind: kind(from: dependency), identifier: dependency.name, versionConstraint: version(from: versionSpecifier))
    }

    private func kind(from dependency: CartfileParser.Dependency) -> CarthageItem.Kind {
        switch dependency {
        case .gitHub:
            return .github
        case .git:
            return .git
        case .binary:
            return .binary
        }
    }

    private func version(from versionSpecifier: CartfileParser.VersionSpecifier) -> VersionConstraint<CarthageItem.Operator>? {
        switch versionSpecifier {
        case .any:
            return nil
        case let .atLeast(semanticVersion):
            return .init(operation: .greaterOrEqual, value: "\(semanticVersion)")
        case let .compatibleWith(semanticVersion):
            return .init(operation: .compatible, value: "\(semanticVersion)")
        case let .exactly(semanticVersion):
            return .init(operation: .equal, value: "\(semanticVersion)")
        case let .gitReference(value):
            return .init(operation: .gitReference, value: value)
        }
    }
}
