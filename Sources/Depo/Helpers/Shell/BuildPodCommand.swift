//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class BuildPodCommand: ShellCommand {

    private let scriptPath: String = AppConfiguration.buildPodShellScriptFilePath

    func callAsFunction(pod: Pod) -> Bool {
        shell(filePath: scriptPath, arguments: [pod.name])
    }
}
