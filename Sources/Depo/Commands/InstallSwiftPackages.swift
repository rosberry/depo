//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class InstallSwiftPackages: ParsableCommand {

    enum CustomError: LocalizedError {
        case badPackageSwiftFile(path: String)
        case badSwiftPackageUpdate
        case badSwiftPackageBuild(packages: [SwiftPackage])
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
        let packages = try self.packages ?? CarPodfile(decoder: options.carpodFileType.decoder).swiftPackages
        let packageSwiftFileName = AppConfiguration.packageSwiftFileName
        let packageSwiftDirName = AppConfiguration.packageSwiftDirectoryName

        try createPackageSwiftFile(at: packageSwiftFileName, with: packages)
        try swiftPackageUpdate()
        try build(packages: packages, at: packageSwiftDirName)

    }

    private func createPackageSwiftFile(at filePath: String, with packages: [SwiftPackage]) throws {
        let buildSettings = try BuildSettings(targetName: nil, shell: shell)
        let content = PackageSwift(projectBuildSettings: buildSettings, items: packages).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: filePath, contents: content) {
            throw CustomError.badPackageSwiftFile(path: filePath)
        }
    }
    
    private func swiftPackageUpdate() throws {
        if !shell("swift", "package", "update") {
            throw CustomError.badSwiftPackageUpdate
        }
    }

    private func build(packages: [SwiftPackage], at path: String) throws {
        let failedPackages = packages.reduce([SwiftPackage]()) { result, package in
            if shell("cd", package.name),
               shell(filePath: buildSwiftPackageScriptPath, arguments: ["GPVA8JVMU3"]) {
                return result
            }
            else {
                return result + [package]
            }
        }
        if !failedPackages.isEmpty {
            throw CustomError.badSwiftPackageBuild(packages: failedPackages)
        }
    }
}
