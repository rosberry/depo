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

    public func callAsFunction(_ args: String) throws -> String {
        try shell(silent: "\(commandPath) \(args)")
    }

    public func callAsFunction(_ args: String) throws -> Int32 {
        try shell(loud: "\(commandPath) \(args)")
    }
}

public protocol ArgumentedShellCommand {

    associatedtype Settings: ShellCommandArguments

    static var keys: [AnyArgument<Settings>] { get }
    var command: String { get }
    var shell: Shell { get }
}

public extension ArgumentedShellCommand {
    @discardableResult
    func callAsFunction(_ command: String? = nil, settings: Settings) throws -> String {
        try shell(silent: "\(command ?? self.command) \(settings.stringArguments(keys: Self.keys).spaceJoined)")
    }
}

public protocol ShellCommandArguments {
}

public extension ShellCommandArguments {
    func stringArguments(keys: [AnyArgument<Self>]) -> [String] {
        keys.reduce([]) { result, argument in
            result + argument.value(self)
        }
    }
}

public extension ArgumentedShellCommand where Self: ShellCommand {
    var command: String {
        commandPath
    }
}
