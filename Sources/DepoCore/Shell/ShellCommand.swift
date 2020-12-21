//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public class ShellCommand: Codable {
    public let shell: Shell
    public let commandPath: String

    public init(commandPath: String, shell: Shell = .init()) {
        self.commandPath = commandPath
        self.shell = shell
    }
}

public protocol ArgumentedShellCommand {

    associatedtype Settings: ShellCommandArguments

    static var keys: [AnyArgument<Settings>] { get }
    var commands: [String] { get }
    var shell: Shell { get }
}

public extension ArgumentedShellCommand {
    @discardableResult
    func callAsFunction(commands: [String]? = nil, _ settings: Settings, environment: [String: String]? = nil) throws -> Shell.IO {
        try shell((commands ?? self.commands) + settings.stringArguments(keys: Self.keys))
    }
}

public protocol ShellCommandArguments {
}

public extension ShellCommandArguments {
    func stringArguments(keys: [AnyArgument<Self>]) -> [String] {
        keys.reduce([]) { acc, argument in
            acc + argument.value(self)
        }
    }
}

public extension ArgumentedShellCommand where Self: ShellCommand {
    var commands: [String] {
        [commandPath]
    }
}
