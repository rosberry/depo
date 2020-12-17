//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public class Lipo: ShellCommand, ArgumentedShellCommand {

    public struct Settings: ShellCommandArguments {
        let actionType: ActionType = .create
        let outputPath: String
        let executablePaths: [String]
    }

    public enum ActionType: String {
        case create
    }

    public static let keys: [AnyArgument<Settings>] =
            [.init(\.actionType, "-"),
             .init(\.outputPath, "-output "),
             .init(\.executablePaths, "", { $0.joined(separator: " ") })]

    public var commands: [String] {
        ["xcrun", commandPath]
    }

    public override init(commandPath: String = AppConfiguration.Path.Absolute.lipo, shell: Shell = .init()) {
        super.init(commandPath: commandPath, shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
