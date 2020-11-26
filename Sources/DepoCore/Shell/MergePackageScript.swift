//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class MergePackageScript: ShellCommand {

    public override init(commandPath: String = AppConfiguration.Path.Absolute.mergePackageShellScript, shell: Shell) {
        super.init(commandPath: commandPath, shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @discardableResult
    public func callAsFunction(swiftFrameworkName: String, outputPath: String) throws -> Shell.IO {
        try shell(filePath: commandPath, arguments: [swiftFrameworkName, ".", outputPath])
    }

    @discardableResult
    public func callAsFunction(pod: Pod, settings: BuildSettings, outputPath: String, buildDir: String) throws -> Shell.IO {
        try self(packageName: settings.productName, schemaName: pod.name, outputPath: outputPath, buildDir: buildDir)
    }

    @discardableResult
    private func callAsFunction(packageName: String, schemaName: String, outputPath: String, buildDir: String) throws -> Shell.IO {
        try shell(filePath: commandPath, arguments: [packageName, schemaName, outputPath, buildDir])
    }
}
