//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public class Lipo: ShellCommand, ArgumentedShellCommand {

    public struct Settings: ShellCommandArguments {
        let actionType: ActionType
        let outputPath: String
        let executablePaths: [String]

        init(actionType: ActionType = .create, outputPath: String, executablePaths: [String]) {
            self.actionType = actionType
            self.outputPath = outputPath
            self.executablePaths = executablePaths
        }
    }

    public enum ActionType: String {
        case create
    }

    public static let keys: [AnyArgument<Settings>] =
            [.init(\.actionType, "-"),
             .init(\.outputPath, "-output "),
             .init(\.executablePaths, "", { $0.joined(separator: " ") })]

    public var command: String {
        "xcrun \(commandPath)"
    }

    public override init(commandPath: String = AppConfiguration.Path.Absolute.lipo, shell: Shell = .init()) {
        super.init(commandPath: commandPath, shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    public func callAsFunction(_ actionType: ActionType, _ outputPath: String, _ executablePaths: [String]) throws -> String {
        let settings = Settings(actionType: actionType, outputPath: outputPath, executablePaths: executablePaths)
        return try self.callAsFunction(settings: settings)
    }
}
