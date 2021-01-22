//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class BuildSwiftPackageScript: ShellCommand {

    private var xcodebuild: XcodeBuild {
        .init(shell: shell)
    }

    private let swiftPackageCommand: SwiftPackageShellCommand

    public init(swiftPackageCommand: SwiftPackageShellCommand, shell: Shell) {
        self.swiftPackageCommand = swiftPackageCommand
        super.init(commandPath: "", shell: shell)
    }

    public required init(from decoder: Decoder) throws {
        fatalError(#file + "\(#line)" + #function)
    }

    @discardableResult
    public func callAsFunction(like frameworkKind: MergePackage.FrameworkKind, buildDir: String, scheme: String) throws -> [Shell.IO] {
        try generateXcodeprojectIfNeeded()
        let derivedDataPath = "build"
        let config = XcodeBuild.Configuration.release
        let xcodebuildOutputs = try build(like: frameworkKind, scheme: scheme, derivedDataPath: derivedDataPath, config: config)
        try moveSwiftPackageBuildProductsToRightPlace(buildDir: buildDir, config: config, derivedDataPath: derivedDataPath)
        return xcodebuildOutputs
    }

    @discardableResult
    private func generateXcodeprojectIfNeeded() throws -> Shell.IO? {
        if !Folder.current.subfolders.contains(with: AppConfiguration.xcodeProjectExtension, at: \.extension) {
            return try swiftPackageCommand.generateXcodeproj()
        }
        else {
            return nil
        }
    }

    private func build(like frameworkKind: MergePackage.FrameworkKind,
                       scheme: String,
                       derivedDataPath: String,
                       config: XcodeBuild.Configuration) throws -> [Shell.IO] {
        let xcodebuild = self.xcodebuild
        switch frameworkKind {
        case .fatFramework:
            return [try xcodebuild(settings: .device(scheme: scheme, configuration: config, derivedDataPath: derivedDataPath)),
                    try xcodebuild(settings: .simulator(scheme: scheme, configuration: config, derivedDataPath: derivedDataPath))]
        case .xcframework:
            return [try xcodebuild.buildForDistribution(settings: .device(scheme: scheme,
                                                                          configuration: config,
                                                                          derivedDataPath: derivedDataPath)),
                try xcodebuild.buildForDistribution(settings: .simulator(scheme: scheme,
                                                                         configuration: config,
                                                                         derivedDataPath: derivedDataPath))]
        }
    }

    private func moveSwiftPackageBuildProductsToRightPlace(buildDir: String,
                                                           config: XcodeBuild.Configuration,
                                                           derivedDataPath: String) throws {
        let rightPlacePath = "\(buildDir)/\(Folder.current.name)/\(config.rawValue)"
        let deviceProductsRightPlaceFolder = try Folder.root.createSubfolderIfNeeded(at: "\(rightPlacePath)-iphoneos")
        let simulatorProductsRightPlaceFolder = try Folder.root.createSubfolderIfNeeded(at: "\(rightPlacePath)-iphonesimulator")

        let productsPath = "\(derivedDataPath)/Build/Products/\(config.rawValue)"
        let deviceProductsFolder = try Folder.current.subfolder(at: "\(productsPath)-iphoneos")
        let simulatorProductsFolder = try Folder.current.subfolder(at: "\(productsPath)-iphonesimulator")

        try deviceProductsRightPlaceFolder.deleteContents()
        try simulatorProductsRightPlaceFolder.deleteContents()
        try deviceProductsFolder.copyContents(to: deviceProductsRightPlaceFolder)
        try simulatorProductsFolder.copyContents(to: simulatorProductsRightPlaceFolder)
    }
}
