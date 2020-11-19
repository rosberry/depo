//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class BuildPodScript: ShellCommand {

    private let scriptPath: String = AppConfiguration.Path.Absolute.buildPodShellScript

    func callAsFunction(pod: Pod) -> Bool {
        shell(filePath: scriptPath, arguments: [pod.name])
    }
}
