//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

public final class CarthageShellCommand: ShellCommand {

    public enum Error: LocalizedError {
        case badBootstrap
        case badUpdate
        case badBuild
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
        try build(command: "update", arguments: arguments)
    }

    public func bootstrap(arguments: [BuildArgument]) throws {
        try build(command: "bootstrap", arguments: arguments)
    }

    public func build() throws {
         if !shell("carthage", "build") {
             throw Error.badBuild
         }
    }

    private func build(command: String, arguments: [BuildArgument]) throws {
        let args: [String] = ["carthage", command] + arguments.reduce([]) { result, arg in
            result + arg.arguments
        }
        if !shell(args) {
            throw Error.badUpdate
        }
    }
}
