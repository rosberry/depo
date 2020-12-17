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

protocol ArgumentedShellCommand {

    associatedtype Settings: ShellCommandArguments

    static var keys: [AnyArgument<Settings>] { get }
    var commands: [String] { get }
    var shell: Shell { get }
}

extension ArgumentedShellCommand {
    func callAsFunction(_ settings: Settings) throws -> Shell.IO {
        try shell(commands + settings.stringArguments(keys: Self.keys))
    }
}

protocol ShellCommandArguments {
}

extension ShellCommandArguments {
    func stringArguments(keys: [AnyArgument<Self>]) -> [String] {
        keys.reduce([]) { acc, argument in
            acc + argument.value(self)
        }
    }
}

extension ArgumentedShellCommand where Self: ShellCommand {
    var commands: [String] {
        [commandPath]
    }
}
