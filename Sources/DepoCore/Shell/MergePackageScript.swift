//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class MergePackageScript: ShellCommand {

    enum Error: Swift.Error {
        case noFramework(path: String)
        case noSwiftModule(path: String)
    }

    private var lipo: Lipo {
        Lipo()
    }

    public init(shell: Shell) {
        super.init(commandPath: "", shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @discardableResult
    public func callAsFunction(swiftFrameworkName: String, outputPath: String) throws -> Shell.IO {
        #warning("schema name is . -- wtf?")
        return try run(packageName: swiftFrameworkName, schemaName: ".", outputPath: outputPath, packageProductsPath: ".")
    }

    @discardableResult
    public func callAsFunction(pod: Pod, settings: BuildSettings, outputPath: String, buildDir: String) throws -> Shell.IO {
        try run(packageName: settings.productName, schemaName: pod.name, outputPath: outputPath, packageProductsPath: buildDir)
    }

    @discardableResult
    private func run(packageName: String, schemaName: String, outputPath: String, packageProductsPath: String) throws -> Shell.IO {
        let outputFrameworkPath = "\(outputPath)/\(packageName).framework"
        let deviceFrameworkPath = "\(packageProductsPath)/Release-iphoneos/\(schemaName)/\(packageName).framework"
        let simulatorFrameworkPath = "\(packageProductsPath)/Release-iphonesimulator/\(schemaName)/\(packageName).framework"

        let binary = self.binary(packageName)
        let deviceFramework = try run(Error.noFramework(path: deviceFrameworkPath), try Folder(path: deviceFrameworkPath))

        let outputFramework = try copy(deviceFramework: deviceFramework,
                                       toOutputFrameworkLocation: outputFrameworkPath,
                                       outputLocation: outputPath)
        let output = try lipo(.init(outputPath: binary(outputFrameworkPath),
                                    executablePaths: [binary(deviceFrameworkPath), binary(simulatorFrameworkPath)]))
        try moveSimulatorsSwiftSubmooduleToFatFramework(simulatorFrameworkPath,
                                                        packageName,
                                                        fatFramework: outputFramework)
        return output
    }

    private func copy(deviceFramework: Folder,
                      toOutputFrameworkLocation outputFrameworkPath: String,
                      outputLocation outputPath: String) throws -> Folder {
        let outputFolder = try Folder.root.createSubfolderIfNeeded(at: outputPath)
        try? Folder.root.createSubfolderIfNeeded(at: outputFrameworkPath).delete()
        return try deviceFramework.copy(to: outputFolder)
    }

    private func moveSimulatorsSwiftSubmooduleToFatFramework(_ simulatorFrameworkPath: String,
                                                             _ packageName: String,
                                                             fatFramework: Folder) throws {
        if let simulatorsSwiftModule = try? Folder(path: "\(simulatorFrameworkPath)/Modules/\(packageName).swiftmodule") {
            let modulesFolder = try fatFramework.subfolder(at: "Modules/\(packageName).swiftmodule")
            try simulatorsSwiftModule.files.forEach { file in
                try file.copy(to: modulesFolder)
            }
        }
    }

    private func run<T>(_ error: Error, _ action: @autoclosure () throws -> T) throws -> T {
        do {
            return try action()
        }
        catch {
            throw error
        }
    }

    private func binary(_ name: String) -> (String) -> String {
        { frameworkPath in
            "\(frameworkPath)/\(name)"
        }
    }
}
