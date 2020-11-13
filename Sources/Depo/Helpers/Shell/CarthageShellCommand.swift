//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class CarthageShellCommand: ShellCommand {

    enum Error: LocalizedError {
        case badBootstrap
        case badUpdate
        case badBuild
    }

    enum BuildArgument {
        case platform(Platform)
        case cacheBuilds

        var arguments: [String] {
            switch self {
            case let .platform(platform):
                return ["--platform", "\(platform.rawValue)"]
            case .cacheBuilds:
                return ["--cache builds"]
            }
        }
    }

    enum Platform: String {
        case mac
        case ios
        case tvos
        case watchos
    }

    func update(arguments: [BuildArgument]) throws {
        try build(command: "update", arguments: arguments)
    }

    func bootstrap(arguments: [BuildArgument]) throws {
        try build(command: "bootstrap", arguments: arguments)
    }

    func build() throws {
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
