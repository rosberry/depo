//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class MergePackageScript: ShellCommand {

    private let scriptPath: String = AppConfiguration.mergePackageShellScriptFilePath

    public func callAsFunction(swiftFrameworkName: String, outputPath: String) -> Bool {
        shell(filePath: scriptPath, arguments: [swiftFrameworkName, ".", outputPath])
    }

    public func callAsFunction(pod: Pod, settings: BuildSettings, outputPath: String, buildDir: String) -> Bool {
        self(packageName: settings.productName, schemaName: pod.name, outputPath: outputPath, buildDir: buildDir)
    }

    private func callAsFunction(packageName: String, schemaName: String, outputPath: String, buildDir: String) -> Bool {
        shell(filePath: scriptPath, arguments: [packageName, schemaName, outputPath, buildDir])
    }
}
