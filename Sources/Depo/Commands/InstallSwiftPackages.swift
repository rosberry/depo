//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import Files

final class InstallSwiftPackages: ParsableCommand {

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

    @OptionGroup()
    private(set) var options: Options

    private let buildSwiftPackageScriptPath: String = AppConfiguration.buildSPShellScriptFilePath

    private let packages: [SwiftPackage]?
    private let shell: Shell = .init()
    private let fmg: FileManager = .default
    private lazy var swiftPackageCommand: SwiftPackageCommand = .init(shell: shell)
    private lazy var mergePackageCommand: MergePackageCommand = .init(shell: shell)

    init() {
        self.packages = nil
    }

    init(packages: [SwiftPackage]) {
        self.packages = packages
    }

    func run() throws {
        let packages = try self.packages ?? Depofile(decoder: options.depoFileType.decoder).swiftPackages
        let packageSwiftFileName = AppConfiguration.packageSwiftFileName
        let packageSwiftDirName = AppConfiguration.packageSwiftDirectoryName
        let packageSwiftBuildsDirName = AppConfiguration.packageSwiftBuildsDirectoryName
        let outputDirName = AppConfiguration.packageSwiftOutputDirectoryName

        try createPackageSwiftFile(at: packageSwiftFileName, with: packages)
        try swiftPackageCommand.update()
        try build(packages: packages, at: packageSwiftDirName, to: packageSwiftBuildsDirName)
        let settings = try buildSettings(packages: packages, at: packageSwiftDirName)
        try proceed(packageContexts: zip(packages, settings), at: packageSwiftBuildsDirName, to: outputDirName)
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
        let failedPackages = packages.filter { package in
            fmg.operate(in: "./\(packagesSourcesPath)/\(package.name)") {
                !shell(filePath: buildSwiftPackageScriptPath, arguments: ["GPVA8JVMU3", "\(projectPath)/\(buildPath)"])
            }
        }
        if !failedPackages.isEmpty {
            throw CustomError.badSwiftPackageBuild(packages: failedPackages)
        }
    }

    private func buildSettings(packages: [SwiftPackage], at packagesSourcesPath: String) throws -> [BuildSettings] {
        try packages.map { package in
            try fmg.operate(in: "./\(packagesSourcesPath)/\(package.name)") {
                return try BuildSettings(targetName: nil, shell: shell)
            }
        }
    }

    private func proceed(packageContexts: Zip2Sequence<[SwiftPackage], [BuildSettings]>,
                         at buildPath: String,
                         to outputPath: String) throws {
        let projectPath = fmg.currentDirectoryPath
        let failedPackages: [SwiftPackage] = try packageContexts.compactMap { (package, settings) in
            let deviceBuildDir = "./\(buildPath)/\(package.name)/Release-iphoneos"
            let frameworks: [String] = (try Folder(path: deviceBuildDir)).subfolders.compactMap { dir in
                dir.extension == "framework" ? dir.nameExcludingExtension : nil
            }
            let failedFrameworks: [String] = fmg.operate(in: "./\(buildPath)/\(package.name)") {
                frameworks.filter { framework in
                    !mergePackageCommand(swiftFrameworkName: framework, outputPath: "\(projectPath)/\(outputPath)")
                }
            }
            return failedFrameworks.isEmpty ? nil : package
        }
        if !failedPackages.isEmpty {
            throw CustomError.badSwiftPackageProceed(packages: failedPackages)
        }
    }
}
