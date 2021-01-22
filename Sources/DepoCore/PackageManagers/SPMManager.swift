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
        case merging(framework: String, MergePackage.FrameworkKind, output: String)
        case done(SwiftPackage)
        case creatingPackageSwiftFile(path: String)
        case shell(state: Shell.State)
        case merge(state: MergePackage.State)
    }

    public enum Error: Swift.Error {
        case badPackageSwiftFile(path: String)
        case badSwiftPackageBuild(contexts: [FailedContext])
        case noDevelopmentTeam
        case noSchemaToBuild(package: SwiftPackage)
    }

    private enum InternalError: Swift.Error {
        case noSchemaToBuild
    }

    private enum CodingKeys: String, CodingKey {
        case options
        case packages
    }

    private let packages: [SwiftPackage]
    private let fmg: FileManager = .default
    private let shell: Shell
    private let xcodebuild: XcodeBuild

    private let swiftPackageCommand: SwiftPackageShellCommand
    private lazy var mergePackage: MergePackage = MergePackage(shell: shell).subscribe { [weak self] state in
        // self?.observer?(.merge(state: state))
    }
    private lazy var buildSwiftPackageScript: BuildSwiftPackageScript = .init(swiftPackageCommand: swiftPackageCommand, shell: shell)

    private let packageSwiftFileName = AppConfiguration.Name.packageSwift
    private let packageSwiftDirName = AppConfiguration.Path.Relative.packageSwiftDirectory
    private let packageSwiftBuildsDirName = AppConfiguration.Path.Relative.packageSwiftBuildsDirectory
    private let outputDirName = AppConfiguration.Path.Relative.packageSwiftOutputDirectory
    private let frameworkKind: MergePackage.FrameworkKind
    private let cacheBuilds: Bool
    private let swiftBuildArguments: String?
    private var observer: ((State) -> Void)?
    private let productExtensions: [String] = ["framework", "xcframework"]
    private var buildsOutputDirectoryPath: String {
        "\(fmg.currentDirectoryPath)/\(packageSwiftBuildsDirName)"
    }
    private var mergedBuildsOutputDirectoryPath: String {
        "\(fmg.currentDirectoryPath)/\(outputDirName)"
    }

    public init(depofile: Depofile,
                swiftCommandPath: String,
                frameworkKind: MergePackage.FrameworkKind,
                cacheBuilds: Bool,
                swiftBuildArguments: String?) {
        let shell = Shell()
        self.shell = shell
        self.xcodebuild = XcodeBuild(shell: shell)
        self.packages = depofile.swiftPackages
        swiftPackageCommand = .init(commandPath: swiftCommandPath, shell: shell)
        self.frameworkKind = frameworkKind
        self.cacheBuilds = cacheBuilds
        self.swiftBuildArguments = swiftBuildArguments
        self.shell.subscribe { [weak self] state in
            self?.observer?(.shell(state: state))
        }
    }

    public func subscribe(_ observer: @escaping (State) -> Void) -> SPMManager {
        self.observer = observer
        return self
    }

    public func update() throws {
        observer?(.updating)
        let buildSettings = try BuildSettings(xcodebuild: xcodebuild)
        try createPackageSwiftFile(at: packageSwiftFileName, with: packages, buildSettings: buildSettings)
        try swiftPackageCommand.update(args: swiftBuildArguments.mapOrEmpty(keyPath: \.words))
        try build()
    }

    public func build() throws {
        observer?(.building)
        try build(packages: packages,
                  like: frameworkKind,
                  at: packageSwiftDirName,
                  buildsOutputDirectoryPath: buildsOutputDirectoryPath,
                  mergedBuildsOutputDirectoryPath: mergedBuildsOutputDirectoryPath)
    }

    private func createPackageSwiftFile(at filePath: String, with packages: [SwiftPackage], buildSettings: BuildSettings) throws {
        observer?(.creatingPackageSwiftFile(path: filePath))
        let spmVersion = try swiftPackageCommand.spmVersion()
        let content = PackageSwift(projectBuildSettings: buildSettings,
                                   spmVersion: spmVersion,
                                   packages: packages).description.data(using: .utf8)
        if !fmg.createFile(atPath: filePath, contents: content) {
            throw Error.badPackageSwiftFile(path: filePath)
        }
    }

    private func build(packages: [SwiftPackage],
                       like frameworkKind: MergePackage.FrameworkKind,
                       at packagesSourcesPath: String,
                       buildsOutputDirectoryPath: String,
                       mergedBuildsOutputDirectoryPath: String) throws {
        let failedPackages = packages.compactMap { package -> FailedContext? in
            do {
                try build(package: package,
                          packagesSourcesDirectoryRelativePath: packagesSourcesPath,
                          packagesBuildsDirectoryRelativePath: buildsOutputDirectoryPath,
                          frameworkKind: frameworkKind)
                try merge(package: package,
                          packagesBuildsDirectoryRelativePath: buildsOutputDirectoryPath,
                          mergedFrameworksDirectoryPath: mergedBuildsOutputDirectoryPath)
                observer?(.done(package))
                return nil
            }
            catch {
                return (error, package)
            }
        }
        if !failedPackages.isEmpty {
            throw Error.badSwiftPackageBuild(contexts: failedPackages)
        }
    }

    private func build(package: SwiftPackage,
                       packagesSourcesDirectoryRelativePath: String,
                       packagesBuildsDirectoryRelativePath: String,
                       frameworkKind: MergePackage.FrameworkKind) throws {
        let path = "./\(packagesSourcesDirectoryRelativePath)/\(package.name)"
        observer?(.buildingPackage(package, path: path))
        try fmg.perform(atPath: path) {
            do {
                try buildPackageInCurrentDir(buildDir: packagesBuildsDirectoryRelativePath, like: frameworkKind)
            }
            catch InternalError.noSchemaToBuild {
                throw Error.noSchemaToBuild(package: package)
            }
        }
    }

    private func buildPackageInCurrentDir(buildDir: String, like frameworkKind: MergePackage.FrameworkKind) throws {
        let _: Int32 = try shell(loud: "chmod -R +rw .")
        guard let schema = try XcodeProjectList(shell: shell).schemes.first else {
            throw InternalError.noSchemaToBuild
        }
        try build(schemes: [schema], like: frameworkKind, buildDir: buildDir)
    }

    private func build(schemes: [String], like frameworkKind: MergePackage.FrameworkKind, buildDir: String) throws {
        try schemes.forEach { scheme in
            try buildSwiftPackageScript(like: frameworkKind, buildDir: buildDir, scheme: scheme)
        }
    }

    private func merge(package: SwiftPackage, packagesBuildsDirectoryRelativePath: String, mergedFrameworksDirectoryPath: String) throws {
        let path = "\(packagesBuildsDirectoryRelativePath)/\(package.name)"
        let deviceBuildDir = "\(path)/Release-iphoneos"
        #warning("proceeding all swift packages seems redundant")
        let frameworks: [String] = (try Folder(path: deviceBuildDir)).subfolders.compactMap { dir in
            dir.extension == "framework" ? dir.nameExcludingExtension : nil
        }
        do {
            try fmg.perform(atPath: path) {
                try frameworks.forEach { framework in
                    observer?(.merging(framework: framework, frameworkKind, output: mergedFrameworksDirectoryPath))
                    try mergePackage.make(frameworkKind, swiftFrameworkName: framework, outputPath: "\(mergedFrameworksDirectoryPath)")
                }
            }
        }
        catch {
            throw error
        }
    }
}
