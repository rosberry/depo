//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class MoveBuiltPodScript: ShellCommand {

    private let scriptPath: String = AppConfiguration.Path.Absolute.moveBuiltPodShellScript

    public func callAsFunction(pod: Pod) -> Bool {
        shell(filePath: scriptPath, arguments: [pod.name])
    }
}
