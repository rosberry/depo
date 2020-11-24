//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class SPMManager: ProgressObservable {

    public enum State {
        case updating
        case building
        case buildingPackage(SwiftPackage, path: String)
        case processing
        case processingPackage(SwiftPackage, path: String)
        case creatingPackageSwiftFile(path: String)
    }

    public enum CustomError: LocalizedError {
        case badPackageSwiftFile(path: String)
        case badSwiftPackageBuild(packages: [SwiftPackage])
        case badSwiftPackageProceed(packages: [SwiftPackage])
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
            throw CustomError.badPackageSwiftFile(path: filePath)
        }
    }

    private func build(packages: [SwiftPackage],
                       at packagesSourcesPath: String,
                       to buildPath: String,
                       teamID: String) throws {
        let projectPath = fmg.currentDirectoryPath
        let failedPackages = try packages.filter { package in
            let path = "./\(packagesSourcesPath)/\(package.name)"
            observer?(.buildingPackage(package, path: path))
            return try fmg.perform(atPath: path) {
                !build(targets: try swiftPackageCommand.targetsOfSwiftPackage(at: packageSwiftFileName),
                       teamID: teamID,
                       buildDir: "\(projectPath)/\(buildPath)")
            }
        }
        if !failedPackages.isEmpty {
            throw CustomError.badSwiftPackageBuild(packages: failedPackages)
        }
    }

    private func build(targets: [String], teamID: String, buildDir: String) -> Bool {
        targets.reduce(true) { result, element in
            result && buildSwiftPackageScript(teamID: teamID, buildDir: buildDir, target: element)
        }
    }

    private func proceed(packages: [SwiftPackage], at buildPath: String, to outputPath: String) throws {
        let projectPath = fmg.currentDirectoryPath
        let failedPackages: [SwiftPackage] = try packages.compactMap { package in
            let path = "./\(buildPath)/\(package.name)"
            observer?(.processingPackage(package, path: path))
            let deviceBuildDir = "\(path)/Release-iphoneos"
            #warning("proceeding all swift packages seems redundant")
            let frameworks: [String] = (try Folder(path: deviceBuildDir)).subfolders.compactMap { dir in
                dir.extension == "framework" ? dir.nameExcludingExtension : nil
            }
            let failedFrameworks: [String] = fmg.perform(atPath: path) {
                frameworks.filter { framework in
                    !mergePackageScript(swiftFrameworkName: framework, outputPath: "\(projectPath)/\(outputPath)")
                }
            }
            return failedFrameworks.isEmpty ? nil : package
        }
        if !failedPackages.isEmpty {
            throw CustomError.badSwiftPackageProceed(packages: failedPackages)
        }
    }

    private func teamID(buildSettings: BuildSettings) throws -> String {
        guard let developmentTeam = buildSettings.developmentTeam else {
            throw CustomError.noDevelopmentTeam
        }
        return developmentTeam
    }
}
