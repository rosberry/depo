//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class MoveBuiltPodScript: ShellCommand {

    public override init(commandPath: String = AppConfiguration.Path.Absolute.moveBuiltPodShellScript, shell: Shell) {
        super.init(commandPath: commandPath, shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @discardableResult
    public func callAsFunction(pod: Pod) throws -> Shell.IO {
        try shell(filePath: commandPath, arguments: [pod.name])
    }
}
