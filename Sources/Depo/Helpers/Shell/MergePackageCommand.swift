//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class MergePackageCommand: ShellCommand {

    private let scriptPath: String = AppConfiguration.mergePackageShellScriptFilePath

    func callAsFunction(swiftFrameworkName: String, outputPath: String) -> Bool {
        shell(filePath: scriptPath, arguments: [swiftFrameworkName, ".", outputPath])
    }

    func callAsFunction(pod: Pod, settings: BuildSettings, outputPath: String, buildDir: String) -> Bool {
        self(packageName: pod.name, schemaName: settings.productName, outputPath: outputPath, buildDir: buildDir)
    }

    private func callAsFunction(packageName: String, schemaName: String, outputPath: String, buildDir: String) -> Bool {
        shell(filePath: scriptPath, arguments: [packageName, schemaName, outputPath, buildDir])
    }
}
