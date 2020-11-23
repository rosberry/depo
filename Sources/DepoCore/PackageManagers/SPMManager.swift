//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class SPMManager: ProgressObservable {

    public enum State {

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
    private let shell: Shell = .init()
    private let fmg: FileManager = .default

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
        let buildSettings = try BuildSettings()
        try createPackageSwiftFile(at: packageSwiftFileName, with: packages, buildSettings: buildSettings)
        try swiftPackageCommand.update()
        try build(packages: packages, at: packageSwiftDirName, to: packageSwiftBuildsDirName, buildSettings: buildSettings)
        try proceed(packages: packages, at: packageSwiftBuildsDirName, to: outputDirName)
    }

    public func build() throws {
        try build(packages: packages, at: packageSwiftDirName, to: packageSwiftBuildsDirName, buildSettings: .init())
        try proceed(packages: packages, at: packageSwiftBuildsDirName, to: outputDirName)
    }

    private func createPackageSwiftFile(at filePath: String, with packages: [SwiftPackage], buildSettings: BuildSettings) throws {
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
