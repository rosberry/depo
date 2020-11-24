//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class MergePackageScript: ShellCommand {

    private let scriptPath: String = AppConfiguration.Path.Absolute.mergePackageShellScript

    @discardableResult
    public func callAsFunction(swiftFrameworkName: String, outputPath: String) throws -> Shell.IO {
        try shell(filePath: scriptPath, arguments: [swiftFrameworkName, ".", outputPath])
    }

    @discardableResult
    public func callAsFunction(pod: Pod, settings: BuildSettings, outputPath: String, buildDir: String) throws -> Shell.IO {
        try self(packageName: settings.productName, schemaName: pod.name, outputPath: outputPath, buildDir: buildDir)
    }

    @discardableResult
    private func callAsFunction(packageName: String, schemaName: String, outputPath: String, buildDir: String) throws -> Shell.IO {
        try shell(filePath: scriptPath, arguments: [packageName, schemaName, outputPath, buildDir])
    }
}
