//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import Files

final class SPMManager: HasUpdateCommand {

    enum CustomError: LocalizedError {
        case badPackageSwiftFile(path: String)
        case badSwiftPackageBuild(packages: [SwiftPackage])
        case badSwiftPackageProceed(packages: [SwiftPackage])
    }

    private enum CodingKeys: String, CodingKey {
        case options
        case packages
    }

    static let configuration: CommandConfiguration = .init(commandName: "swift-package-install")

    private let packages: [SwiftPackage]
    private let shell: Shell = .init()
    private let fmg: FileManager = .default

    private lazy var swiftPackageCommand: SwiftPackageShellCommand = .init(shell: shell)
    private lazy var mergePackageScript: MergePackageScript = .init(shell: shell)
    private lazy var buildSwiftPackageScript: BuildSwiftPackageScript = .init(shell: shell)

    init(depofile: Depofile) {
        self.packages = depofile.swiftPackages
    }

    func update() throws {
        let packageSwiftFileName = AppConfiguration.packageSwiftFileName
        let packageSwiftDirName = AppConfiguration.packageSwiftDirectoryName
        let packageSwiftBuildsDirName = AppConfiguration.packageSwiftBuildsDirectoryName
        let outputDirName = AppConfiguration.packageSwiftOutputDirectoryName

        try createPackageSwiftFile(at: packageSwiftFileName, with: packages)
        try swiftPackageCommand.update()
        try build(packages: packages, at: packageSwiftDirName, to: packageSwiftBuildsDirName)
        try proceed(packages: packages, at: packageSwiftBuildsDirName, to: outputDirName)
    }

    private func createPackageSwiftFile(at filePath: String, with packages: [SwiftPackage]) throws {
        let buildSettings = try BuildSettings(targetName: nil, shell: shell)
        let content = PackageSwift(projectBuildSettings: buildSettings, items: packages).description.data(using: .utf8)
        if !fmg.createFile(atPath: filePath, contents: content) {
            throw CustomError.badPackageSwiftFile(path: filePath)
        }
    }

    private func build(packages: [SwiftPackage], at packagesSourcesPath: String, to buildPath: String) throws {
        let projectPath = fmg.currentDirectoryPath
        #warning("hardcoded teamID")
        let failedPackages = packages.filter { package in
            fmg.operate(in: "./\(packagesSourcesPath)/\(package.name)") {
                !buildSwiftPackageScript(teamID: "GPVA8JVMU3", buildDir: "\(projectPath)/\(buildPath)")
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
            let failedFrameworks: [String] = fmg.operate(in: "./\(buildPath)/\(package.name)") {
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
