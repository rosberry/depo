//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import Files

fileprivate let fmg: FileManager = .default

final class InstallSwiftPackages: ParsableCommand {

    enum CustomError: LocalizedError {
        case badPackageSwiftFile(path: String)
        case badSwiftPackageUpdate
        case badSwiftPackageBuild(packages: [SwiftPackage])
        case badSwiftPackageProceed(packages: [SwiftPackage])
    }

    static let configuration: CommandConfiguration = .init(commandName: "swift-package-install")

    @OptionGroup()
    private(set) var options: Options

    private let buildSwiftPackageScriptPath: String = AppConfiguration.buildSPShellScriptFilePath

    private let packages: [SwiftPackage]?
    private let shell: Shell = .init()

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

        try createPackageSwiftFile(at: packageSwiftFileName, with: packages)
        try swiftPackageUpdate()
        try build(packages: packages, at: packageSwiftDirName)
        try proceed(packages: packages, at: packageSwiftDirName)
    }

    private func createPackageSwiftFile(at filePath: String, with packages: [SwiftPackage]) throws {
        let buildSettings = try BuildSettings(targetName: nil, shell: shell)
        let content = PackageSwift(projectBuildSettings: buildSettings, items: packages).description.data(using: .utf8)
        if !fmg.createFile(atPath: filePath, contents: content) {
            throw CustomError.badPackageSwiftFile(path: filePath)
        }
    }
    
    private func swiftPackageUpdate() throws {
        if !shell("swift", "package", "update") {
            throw CustomError.badSwiftPackageUpdate
        }
    }

    private func build(packages: [SwiftPackage], at path: String) throws {
        let currentPath = fmg.currentDirectoryPath
        fmg.changeCurrentDirectoryPath(path)
        let failedPackages = packages.filter { package in
            !shell(filePath: buildSwiftPackageScriptPath, arguments: ["GPVA8JVMU3", package.name])
        }
        fmg.changeCurrentDirectoryPath(currentPath)
        if !failedPackages.isEmpty {
            throw CustomError.badSwiftPackageBuild(packages: failedPackages)
        }
    }

    private func proceed(packages: [SwiftPackage], at path: String) throws {
        let currentPath = fmg.currentDirectoryPath
        fmg.changeCurrentDirectoryPath(path)
        let buildSettings: [BuildSettings] = try packages.map { package in
            try fmg.operate(in: "./\(package.name)") {
                try BuildSettings(targetName: nil, shell: shell)
            }
        }
        fmg.changeCurrentDirectoryPath("./build")
        let failedPackages: [SwiftPackage] = try zip(packages, buildSettings).compactMap { (package, settings) in
            let frameworks: [String] = (try Folder(path: "./\(package.name)/Release-iphoneos")).subfolders.compactMap { dir in
                dir.extension == "framework" ? dir.nameExcludingExtension : nil
            }
            let failedFrameworks: [String] = fmg.operate(in: "./\(package.name)") {
                frameworks.filter { framework in
                    !shell(filePath: AppConfiguration.mergePodShellScriptFilePath, arguments: [".", framework, "../../../../SPM/", "."])
                }
            }
            return failedFrameworks.isEmpty ? nil : package
        }
        fmg.changeCurrentDirectoryPath(currentPath)
        if !failedPackages.isEmpty {
            throw CustomError.badSwiftPackageProceed(packages: failedPackages)
        }
    }
}
