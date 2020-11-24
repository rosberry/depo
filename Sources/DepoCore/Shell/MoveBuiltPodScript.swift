//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class MoveBuiltPodScript: ShellCommand {

    private let scriptPath: String = AppConfiguration.Path.Absolute.moveBuiltPodShellScript

    @discardableResult
    public func callAsFunction(pod: Pod) throws -> Shell.IO {
        try shell(filePath: scriptPath, arguments: [pod.name])
    }
}
