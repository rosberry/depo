//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import Files
import CartfileParser

public final class CarthageShellCommand: ShellCommand {

    public enum Error: LocalizedError {
        case badCarthage(command: String, arguments: [BuildArgument])
    }

    public enum BuildArgument {
        case platform(Platform)
        case cacheBuilds

        public var arguments: [String] {
            switch self {
            case let .platform(platform):
                return platformArguments(platform: platform)
            case .cacheBuilds:
                return ["--cache builds"]
            }
        }

        private func platformArguments(platform: Platform) -> [String] {
            switch platform {
            case .all:
                return []
            default:
                return ["--platform", platform.rawValue]
            }
        }
    }

    public func update(arguments: [BuildArgument]) throws {
        try carthage("update", arguments: arguments)
    }

    public func bootstrap(arguments: [BuildArgument]) throws {
        try carthage("bootstrap", arguments: arguments)
    }

    public func build() throws {
        try carthage("build", arguments: [])
    }

    public func cartfile(url: URL) throws -> Cartfile {
        cartfile(from: try CartfileParser.Cartfile.from(file: url).get())
    }

    public func cartfile(path: String) throws -> Cartfile {
        try cartfile(url: try Folder.current.file(at: path).url)
    }

    private func carthage(_ command: String, arguments: [BuildArgument]) throws {
        let args: [String] = ["carthage", command] + arguments.reduce([]) { result, arg in
            result + arg.arguments
        }
        if !shell(args) {
            throw Error.badCarthage(command: command, arguments: arguments)
        }
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
