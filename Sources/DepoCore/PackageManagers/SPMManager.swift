//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class SPMManager: ProgressObservable {

    public enum State {
        case updating
        case building
        case buildingPackage(SwiftPackage)
        case processing
        case processingPackage(SwiftPackage)
        case creatingPackageSwiftFile(path: String)
    }

    public enum CustomError: LocalizedError {
        case badPackageSwiftFile(path: String)
        case badSwiftPackageBuild(packages: [SwiftPackage])
        case badSwiftPackageProceed(packages: [SwiftPackage])
    }

    private enum CodingKeys: String, CodingKey {
        case options
        case packages
    }

    private let packages: [SwiftPackage]
    private let fmg: FileManager = .default
    private let shell: Shell = Shell().subscribe { state in
        print(state)
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
        try build(packages: packages, at: packageSwiftDirName, to: packageSwiftBuildsDirName, buildSettings: buildSettings)
        observer?(.processing)
        try proceed(packages: packages, at: packageSwiftBuildsDirName, to: outputDirName)
    }

    public func build() throws {
        observer?(.building)
        try build(packages: packages, at: packageSwiftDirName, to: packageSwiftBuildsDirName, buildSettings: .init(shell: shell))
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
                       buildSettings: BuildSettings) throws {
        let projectPath = fmg.currentDirectoryPath
        let failedPackages = packages.filter { package in
            observer?(.buildingPackage(package))
            fmg.perform(atPath: "./\(packagesSourcesPath)/\(package.name)") {
                !buildSwiftPackageScript(teamID: buildSettings.developmentTeam, buildDir: "\(projectPath)/\(buildPath)")
            }
        }
        if !failedPackages.isEmpty {
            throw CustomError.badSwiftPackageBuild(packages: failedPackages)
        }
    }

    private func proceed(packages: [SwiftPackage], at buildPath: String, to outputPath: String) throws {
        let projectPath = fmg.currentDirectoryPath
        let failedPackages: [SwiftPackage] = try packages.compactMap { package in
            observer?(.processingPackage(package))
            let deviceBuildDir = "./\(buildPath)/\(package.name)/Release-iphoneos"
            #warning("proceeding all swift packages seems redundant")
            let frameworks: [String] = (try Folder(path: deviceBuildDir)).subfolders.compactMap { dir in
                dir.extension == "framework" ? dir.nameExcludingExtension : nil
            }
            let failedFrameworks: [String] = fmg.perform(atPath: "./\(buildPath)/\(package.name)") {
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
}
