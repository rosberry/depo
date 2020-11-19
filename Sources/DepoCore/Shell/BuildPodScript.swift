//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class BuildPodScript: ShellCommand {

    private let scriptPath: String = AppConfiguration.Path.Absolute.buildPodShellScript

    public func callAsFunction(pod: Pod) -> Bool {
        shell(filePath: scriptPath, arguments: [pod.name])
    }
}
