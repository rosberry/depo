//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class SPMManager: ProgressObservable {

    public typealias FailedContext = (Swift.Error, SwiftPackage)

    public enum State {
        case updating
        case building
        case buildingPackage(SwiftPackage, path: String)
        case processing
        case processingPackage(SwiftPackage, path: String)
        case creatingPackageSwiftFile(path: String)
    }

    public enum Error: Swift.Error {
        case badPackageSwiftFile(path: String)
        case badSwiftPackageBuild(contexts: [FailedContext])
        case badSwiftPackageProceed(contexts: [FailedContext])
        case noDevelopmentTeam
    }

    private enum CodingKeys: String, CodingKey {
        case options
        case packages
    }

    private let packages: [SwiftPackage]
    private let fmg: FileManager = .default
    private let shell: Shell = Shell().subscribe { state in
        print("spm:", state)
    }

    private lazy var swiftPackageCommand: SwiftPackageShellCommand = .init(shell: shell)
    private lazy var mergePackageScript: MergePackageScript = .init(shell: shell)
    private lazy var buildSwiftPackageScript: BuildSwiftPackageScript = .init(shell: shell)

    private let packageSwiftFileName = AppConfiguration.Name.packageSwift
    private let packageSwiftDirName = AppConfiguration.Path.Relative.packageSwiftDirectory
    private let packageSwiftBuildsDirName = AppConfiguration.Path.Relative.packageSwiftBuildsDirectory
    private let outputDirName = AppConfiguration.Path.Relative.packageSwiftOutputDirectory
    private var observer: ((State) -> Void)?

    public init(depofile: Depofile) {
        self.packages = depofile.swiftPackages
    }

    public func subscribe(_ observer: @escaping (State) -> Void) -> SPMManager {
        self.observer = observer
        return self
    }

    public func update() throws {
        observer?(.updating)
        let buildSettings = try BuildSettings(shell: shell)
        try createPackageSwiftFile(at: packageSwiftFileName, with: packages, buildSettings: buildSettings)
        try swiftPackageCommand.update()
        observer?(.building)
        try build(packages: packages,
                  at: packageSwiftDirName,
                  to: packageSwiftBuildsDirName,
                  teamID: try teamID(buildSettings: buildSettings))
        observer?(.processing)
        try proceed(packages: packages, at: packageSwiftBuildsDirName, to: outputDirName)
    }

    public func build() throws {
        observer?(.building)
        let buildSettings = try BuildSettings(shell: shell)
        try build(packages: packages,
                  at: packageSwiftDirName,
                  to: packageSwiftBuildsDirName,
                  teamID: try teamID(buildSettings: buildSettings))
        observer?(.processing)
        try proceed(packages: packages, at: packageSwiftBuildsDirName, to: outputDirName)
    }

    private func createPackageSwiftFile(at filePath: String, with packages: [SwiftPackage], buildSettings: BuildSettings) throws {
        observer?(.creatingPackageSwiftFile(path: filePath))
        let content = PackageSwift(projectBuildSettings: buildSettings, packages: packages).description.data(using: .utf8)
        if !fmg.createFile(atPath: filePath, contents: content) {
            throw Error.badPackageSwiftFile(path: filePath)
        }
    }

    private func build(packages: [SwiftPackage],
                       at packagesSourcesPath: String,
                       to buildPath: String,
                       teamID: String) throws {
        let projectPath = fmg.currentDirectoryPath
        let failedPackages = packages.compactMap { package -> FailedContext? in
            let path = "./\(packagesSourcesPath)/\(package.name)"
            observer?(.buildingPackage(package, path: path))
            return fmg.perform(atPath: path) {
                do {
                    try build(targets: try swiftPackageCommand.targetsOfSwiftPackage(at: packageSwiftFileName),
                              teamID: teamID,
                              buildDir: "\(projectPath)/\(buildPath)")
                    return nil
                }
                catch {
                    return (error, package)
                }
            }
        }
        if !failedPackages.isEmpty {
            throw Error.badSwiftPackageBuild(contexts: failedPackages)
        }
    }

    private func build(targets: [String], teamID: String, buildDir: String) throws {
        try targets.forEach { element in
            try buildSwiftPackageScript(teamID: teamID, buildDir: buildDir, target: element)
        }
    }

    private func proceed(packages: [SwiftPackage], at buildPath: String, to outputPath: String) throws {
        let projectPath = fmg.currentDirectoryPath
        let failedPackages: [FailedContext] = try packages.compactMap { package in
            let path = "./\(buildPath)/\(package.name)"
            observer?(.processingPackage(package, path: path))
            let deviceBuildDir = "\(path)/Release-iphoneos"
            #warning("proceeding all swift packages seems redundant")
            let frameworks: [String] = (try Folder(path: deviceBuildDir)).subfolders.compactMap { dir in
                dir.extension == "framework" ? dir.nameExcludingExtension : nil
            }
            do {
                try fmg.perform(atPath: path) {
                    try frameworks.forEach { framework in
                        try mergePackageScript(swiftFrameworkName: framework, outputPath: "\(projectPath)/\(outputPath)")
                    }
                }
                return nil
            }
            catch {
                return (error, package)
            }
        }
        if !failedPackages.isEmpty {
            throw Error.badSwiftPackageProceed(contexts: failedPackages)
        }
    }

    private func teamID(buildSettings: BuildSettings) throws -> String {
        guard let developmentTeam = buildSettings.developmentTeam else {
            throw Error.noDevelopmentTeam
        }
        return developmentTeam
    }
}
