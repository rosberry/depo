//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class SPMManager: ProgressObservable, PackageManager {

    public typealias Package = SwiftPackage
    public typealias BuildResult = PackageOutput<Package>

    public enum State {
        case updating
        case building
        case buildingPackage(SwiftPackage, path: String)
        case merging(framework: String, MergePackage.FrameworkKind, output: String)
        case done(SwiftPackage)
        case doneWithError(SwiftPackage, Swift.Error)
        case creatingPackageSwiftFile(path: String)
        case shell(state: Shell.State)
        case merge(state: MergePackage.State)
    }

    public enum Error: Swift.Error {
        case badPackageSwiftFile(path: String)
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

    public enum BuildKind: CaseIterable {
        case xcframework
        case fat
        case staticLib
    }

    public static let keyPath: KeyPath<Depofile, [Package]> = \.swiftPackages
    public static let outputPath: String = AppConfiguration.Path.Relative.packageSwiftOutputDirectory

    public let packages: [Package]
    private let fmg: FileManager = .default
    private let shell: Shell
    private let xcodebuild: XcodeBuild

    private let swiftPackageCommand: SwiftPackageShellCommand
    private lazy var mergePackage: MergePackage = MergePackage(shell: shell)
    private lazy var buildSwiftPackageScript: BuildSwiftPackageScript = .init(swiftPackageCommand: swiftPackageCommand, shell: shell)
    private let swiftCommandPath: String

    private let packageSwiftFileName = AppConfiguration.Name.packageSwift
    private let packageSwiftDirName = AppConfiguration.Path.Relative.packageSwiftDirectory
    private let packageSwiftBuildsDirName = AppConfiguration.Path.Relative.packageSwiftBuildsDirectory
    private let outputDirName = AppConfiguration.Path.Relative.packageSwiftOutputDirectory

    private let buildKind: BuildKind
    private let swiftBuildArguments: String?
    private var observer: ((State) -> Void)?
    private let productExtensions: [String] = ["framework", "xcframework"]
    private lazy var staticLibraryBuildService: StaticLibraryBuilderService = {
        let service = StaticLibraryBuilderService(swiftCommandPath: swiftCommandPath)
        service.subscribe { state in
            print(state)
        }
        return service
    }()

    private var buildsOutputDirectoryPath: String {
        "\(fmg.currentDirectoryPath)/\(packageSwiftBuildsDirName)"
    }
    private var mergedBuildsOutputDirectoryPath: String {
        "\(fmg.currentDirectoryPath)/\(outputDirName)"
    }

    public init(packages: [Package],
                swiftCommandPath: String,
                buildKind: BuildKind,
                swiftBuildArguments: String?) {
        self.packages = packages
        let shell = Shell()
        self.shell = shell
        self.xcodebuild = XcodeBuild(shell: shell)
        self.swiftCommandPath = swiftCommandPath
        self.swiftPackageCommand = .init(commandPath: swiftCommandPath, shell: shell)
        self.buildKind = buildKind
        self.swiftBuildArguments = swiftBuildArguments
        self.shell.subscribe { [weak self] state in
            self?.observer?(.shell(state: state))
        }
    }

    public convenience init(packages: [Package],
                            swiftCommandPath: String,
                            frameworkKind: MergePackage.FrameworkKind,
                            swiftBuildArguments: String?) {
        self.init(packages: packages,
                  swiftCommandPath: swiftCommandPath,
                  buildKind: frameworkKind == .fatFramework ? .fat : .xcframework,
                  swiftBuildArguments: swiftBuildArguments)
    }

    public func subscribe(_ observer: @escaping (State) -> Void) -> SPMManager {
        self.observer = observer
        return self
    }

    public func install() throws -> PackagesOutput<Package> {
        fatalError("install() has not been implemented")
    }

    public func update() throws -> [BuildResult] {
        observer?(.updating)
        let buildSettings = try BuildSettings(xcodebuild: xcodebuild)
        try createPackageSwiftFile(at: packageSwiftFileName, with: packages, buildSettings: buildSettings)
        try swiftPackageCommand.update(args: swiftBuildArguments.mapOrEmpty(keyPath: \.words))
        return try build()
    }

    public func build() throws -> [BuildResult] {
        observer?(.building)
        return build(packages: packages,
                     like: buildKind,
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

    // swiftlint:disable:next function_parameter_count
    private func build(packages: [SwiftPackage],
                       like buildKind: BuildKind,
                       at packagesSourcesPath: String,
                       buildsOutputDirectoryPath: String,
                       mergedBuildsOutputDirectoryPath: String) -> [BuildResult] {
        let build: (SwiftPackage) throws -> BuildResult = {
            switch buildKind {
            case .xcframework:
                return { package in
                    try self.buildFramework(package: package,
                                            packagesSourcesPath: packagesSourcesPath,
                                            frameworkKind: .xcframework)
                }
            case .fat:
                return { package in
                    try self.buildFramework(package: package,
                                            packagesSourcesPath: packagesSourcesPath,
                                            frameworkKind: .fatFramework)
                }
            case .staticLib:
                return { package in
                    let path = "./\(packagesSourcesPath)/\(package.name)"
                    let scheme = package.name
                    return try self.fmg.perform(atPath: path) {
                        let result = try self.staticLibraryBuildService.build(scheme: scheme, derivedDataPath: nil)
                        return .success((package, [result]))
                    }
                }
            }
        }()
        return packages.map { package -> BuildResult in
            do {
                return try build(package)
            }
            catch {
                return .failure(.init(error: error, value: package))
            }
        }
    }

    private func buildFramework(package: SwiftPackage,
                                packagesSourcesPath: String,
                                frameworkKind: MergePackage.FrameworkKind) throws -> BuildResult {
        try build(package: package,
                  packagesSourcesDirectoryRelativePath: packagesSourcesPath,
                  packagesBuildsDirectoryRelativePath: buildsOutputDirectoryPath,
                  frameworkKind: frameworkKind)
        let mergeOutputs = try merge(package: package,
                                     packagesBuildsDirectoryRelativePath: buildsOutputDirectoryPath,
                                     mergedFrameworksDirectoryPath: mergedBuildsOutputDirectoryPath,
                                     frameworkKind: frameworkKind)
        observer?(.done(package))
        return .success((package, mergeOutputs.map(by: \.mergedFrameworkPath)))
    }

    private func build(package: SwiftPackage,
                       packagesSourcesDirectoryRelativePath: String,
                       packagesBuildsDirectoryRelativePath: String,
                       frameworkKind: MergePackage.FrameworkKind) throws {
        let path = "./\(packagesSourcesDirectoryRelativePath)/\(package.name)"
        observer?(.buildingPackage(package, path: path))
        try fmg.perform(atPath: path) {
            do {
                let xcodeProjectCreationOutput = try buildSwiftPackageScript.generateXcodeprojectIfNeeded()
                defer {
                    try? buildSwiftPackageScript.deleteXcodeprojectIfCreated(creationOutput: xcodeProjectCreationOutput)
                }
                try buildPackageInCurrentDir(buildDir: packagesBuildsDirectoryRelativePath, like: frameworkKind)
            }
            catch InternalError.noSchemaToBuild {
                throw Error.noSchemaToBuild(package: package)
            }
        }
    }

    private func buildPackageInCurrentDir(buildDir: String, like frameworkKind: MergePackage.FrameworkKind) throws {
        let _: Int32 = try shell(loud: "chmod -R +rw .")
        let contexts = try xcodebuild.schemes().compactMap { scheme -> BuildSwiftPackageScript.BuildContext? in
            guard let settings = try? BuildSettings(scheme: scheme, xcodebuild: xcodebuild) else {
                return nil
            }
            return shouldBuild(settings: settings) ? (scheme, settings) : nil
        }
        try build(contexts: contexts, like: frameworkKind, buildDir: buildDir)
    }

    private func build(contexts: [BuildSwiftPackageScript.BuildContext],
                       like frameworkKind: MergePackage.FrameworkKind,
                       buildDir: String) throws {
        try contexts.forEach { context in
            try buildSwiftPackageScript(like: frameworkKind, context: context, buildDir: buildDir)
        }
    }

    private func merge(package: SwiftPackage,
                       packagesBuildsDirectoryRelativePath: String,
                       mergedFrameworksDirectoryPath: String,
                       frameworkKind: MergePackage.FrameworkKind) throws -> [MergePackage.Output] {
        let path = "\(packagesBuildsDirectoryRelativePath)/\(package.name)"
        let deviceBuildDir = "\(path)/Release-iphoneos"
        #warning("proceeding all swift packages seems redundant")
        let frameworks: [String] = (try Folder(path: deviceBuildDir)).subfolders.compactMap { dir in
            dir.extension == "framework" ? dir.nameExcludingExtension : nil
        }
        do {
            return try fmg.perform(atPath: path) {
                try frameworks.map { framework -> MergePackage.Output in
                    observer?(.merging(framework: framework, frameworkKind, output: mergedFrameworksDirectoryPath))
                    return try mergePackage.make(frameworkKind,
                                                 swiftFrameworkName: framework,
                                                 outputPath: "\(mergedFrameworksDirectoryPath)")
                }
            }
        }
        catch {
            throw error
        }
    }

    private func shouldBuild(settings: BuildSettings) -> Bool {
        settings.productType == .framework && settings.supportedPlatforms.contains(.ios)
    }
}
