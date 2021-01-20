//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class MergePackage: ShellCommand {

    public enum Error: Swift.Error {
        case noFramework(path: String)
        case noSwiftModule(path: String)
        case badMove(tmpXCFrameworkPath: String, outputXCFrameworkPath: String)
    }

    public enum FrameworkKind: CaseIterable {
        case fatFramework
        case xcframework
    }

    private var observer: ((State) -> Void)?
    private var lipo: Lipo {
        .init(shell: shell)
    }

    private var xcodebuild: XcodeBuild {
        .init(shell: shell)
    }

    public init(shell: Shell) {
        super.init(commandPath: "", shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    @discardableResult
    public func make(_ frameworkKind: FrameworkKind, swiftFrameworkName: String, outputPath: String) throws -> Shell.IO {
        observer?(.makingSP(name: swiftFrameworkName, kind: frameworkKind, outputPath: outputPath))
        switch frameworkKind {
        case .fatFramework:
            return try makeFatFramework(swiftFrameworkName: swiftFrameworkName, outputPath: outputPath)
        case .xcframework:
            return try makeXCFramework(swiftFrameworkName: swiftFrameworkName, outputPath: outputPath)
        }
    }

    @discardableResult
    //swiftlint:disable:next function_parameter_count
    public func make(_ frameworkKind: FrameworkKind,
                     pod: Pod,
                     settings: BuildSettings,
                     outputPath: String,
                     buildDir: String) throws -> Shell.IO {
        observer?(.makingPod(name: pod.name, kind: frameworkKind, outputPath: outputPath))
        switch frameworkKind {
        case .fatFramework:
            return try makeFatFramework(pod: pod, settings: settings, outputPath: outputPath, buildDir: buildDir)
        case .xcframework:
            return try makeXCFramework(pod: pod, settings: settings, outputPath: outputPath, buildDir: buildDir)
        }
    }

    @discardableResult
    private func makeFatFramework(swiftFrameworkName: String, outputPath: String) throws -> Shell.IO {
        #warning("schema name is . -- wtf?")
        return try mergeFat(packageName: swiftFrameworkName,
                            schemaName: ".",
                            outputPath: outputPath,
                            packageProductsPath: ".")
    }

    @discardableResult
    private func makeXCFramework(swiftFrameworkName: String, outputPath: String) throws -> Shell.IO {
        try mergeXC(packageName: swiftFrameworkName,
                    schemaName: ".",
                    outputPath: outputPath,
                    packageProductsPath: ".")
    }

    @discardableResult
    private func makeFatFramework(pod: Pod, settings: BuildSettings, outputPath: String, buildDir: String) throws -> Shell.IO {
        try mergeFat(packageName: settings.productName,
                     schemaName: pod.name,
                     outputPath: outputPath,
                     packageProductsPath: buildDir)
    }

    @discardableResult
    private func makeXCFramework(pod: Pod, settings: BuildSettings, outputPath: String, buildDir: String) throws -> Shell.IO {
        try mergeXC(packageName: settings.productName,
                    schemaName: pod.name,
                    outputPath: outputPath,
                    packageProductsPath: buildDir)
    }

    @discardableResult
    private func mergeFat(packageName: String, schemaName: String, outputPath: String, packageProductsPath: String) throws -> Shell.IO {
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

    @discardableResult
    private func mergeXC(packageName: String, schemaName: String, outputPath: String, packageProductsPath: String) throws -> Shell.IO {
        let tmpXCFrameworkPath = "\(Folder.temporary.path)/\(packageName).xcframework"
        let outputXCFrameworkPath = "\(outputPath)/\(packageName).xcframework"
        let deviceFrameworkPath = "\(packageProductsPath)/Release-iphoneos/\(schemaName)/\(packageName).framework"
        let simulatorFrameworkPath = "\(packageProductsPath)/Release-iphonesimulator/\(schemaName)/\(packageName).framework"

        let result = try xcodebuild.create(xcFrameworkAt: tmpXCFrameworkPath,
                                           fromFrameworksAtPaths: [deviceFrameworkPath, simulatorFrameworkPath])
        try move(tmpXCFrameworkPath: tmpXCFrameworkPath, outputDirectoryPath: outputPath, outputXCFrameworkPath: outputXCFrameworkPath)
        return result
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

    private func move(tmpXCFrameworkPath: String, outputDirectoryPath: String, outputXCFrameworkPath: String) throws {
        do {
            try (try? Folder(path: outputXCFrameworkPath))?.delete()
            let tmpXCFrameworkFolder = try Folder(path: tmpXCFrameworkPath)
            let outputFolder = try Folder(path: outputDirectoryPath)
            try tmpXCFrameworkFolder.move(to: outputFolder)
        }
        catch {
            throw Error.badMove(tmpXCFrameworkPath: tmpXCFrameworkPath, outputXCFrameworkPath: outputXCFrameworkPath)
        }
    }
}

extension MergePackage: ProgressObservable {

    public enum State {
        case makingSP(name: String, kind: FrameworkKind, outputPath: String)
        case makingPod(name: String, kind: FrameworkKind, outputPath: String)
    }

    public func subscribe(_ observer: @escaping (State) -> Void) -> MergePackage {
        self.observer = observer
        return self
    }
}
