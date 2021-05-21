//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import PathKit

public final class StaticLibraryBuilderService: ProgressObservable {

    public typealias Output = String

    public enum State {
        case shell(state: Shell.State)
        case buildSchemeForEachSDK
        case makeStaticLibraryPerSDK
        case makeFatStaticLibrary
        case collectingSwiftModules
    }

    private var observer: ((State) -> Void)?
    private lazy var xcodebuild: XcodeBuild = .init(shell: shell)
    private lazy var lipo: Lipo = .init(shell: shell)

    private lazy var shell: Shell = Shell().subscribe { [weak self] state in
        self?.observer?(.shell(state: state))
    }

    public init() {

    }

    public func build(scheme: String, derivedDataPath: String) throws -> Output {
        try deleteXcprojectAndXcworskpaces()
        try buildSmallLibs(scheme: scheme, derivedDataPath: derivedDataPath)

        let sdkBuildOutputs = Path.glob("\(derivedDataPath)/Build/Products/*")

        let staticLibsPerSDK = try makeStaticLibForEachSDK(sdkBuildOutputs: sdkBuildOutputs, scheme: scheme)
        let outputLibPath = Path("\(scheme).lib")
        let tmpLibPath = Path("\(derivedDataPath)/\(scheme).lib")

        try tmpLibPath.deleteIfExists()

        try makeFatStaticLibrary(smallLibs: staticLibsPerSDK, at: tmpLibPath)
        try collectSwiftModules(productPaths: sdkBuildOutputs, output: tmpLibPath)

        try tmpLibPath.overwrite(outputLibPath)
        return outputLibPath.description
    }

    @discardableResult
    public func subscribe(_ observer: @escaping (State) -> Void) -> Self {
        self.observer = observer
        return self
    }

    private func deleteXcprojectAndXcworskpaces() throws {
        let projects = Path.glob("*.xcproject")
        let workspaces = Path.glob("*.xcworkspace")
        for item in (projects + workspaces) {
            try item.delete()
        }
    }

    private func buildSmallLibs(scheme: String, derivedDataPath: String) throws {
        observer?(.buildSchemeForEachSDK)
        let simSettings = XcodeBuild.Settings.simulator(scheme: scheme,
                                                        derivedDataPath: derivedDataPath,
                                                        isSigning: false)
        let devSettings = XcodeBuild.Settings.device(scheme: scheme,
                                                     derivedDataPath: derivedDataPath,
                                                     isSigning: false)
        _ = try xcodebuild(settings: simSettings)
        _ = try xcodebuild(settings: devSettings)
    }

    private func makeStaticLibForEachSDK(sdkBuildOutputs: [Path], scheme: String) throws -> [Path] {
        observer?(.makeStaticLibraryPerSDK)
        return try sdkBuildOutputs.map { buildOutputPath in
            try makeStaticLibrary(productPath: buildOutputPath, name: "lib\(scheme).a")
        }
    }

    private func makeStaticLibrary(productPath: Path, name: String) throws -> Path {
        let libPath = "\(productPath)\(name)"
        let objects = productPath.glob("*.o")
        _ = try shell(silent: "ar -rcs \(libPath) \(objects.map(by: \.description).spaceJoined)")
        return Path(libPath)
    }

    private enum FatStaticLibError: Error {
        case emptySmallLibs
    }

    private func makeFatStaticLibrary(smallLibs: [Path], at libPath: Path) throws {
        observer?(.makeFatStaticLibrary)
        guard let firstSmallLib = smallLibs.first else {
            throw FatStaticLibError.emptySmallLibs
        }
        try libPath.mkdir()
        let outputPath = "\(libPath)/\(firstSmallLib.lastComponent)"
        let executables = smallLibs.map(by: \.description)
        try lipo(.create, outputPath, executables)
        for smallLib in smallLibs {
            try? smallLib.delete()
        }
    }

    private enum CollectingSwiftModulesError: Error {
        case noSwiftModules
    }

    private func collectSwiftModules(productPaths: [Path], output: Path) throws {
        observer?(.collectingSwiftModules)
        for productPath in productPaths {
            let swiftModules = productPath.glob("*.swiftmodule")
            guard !swiftModules.isEmpty else {
                throw CollectingSwiftModulesError.noSwiftModules
            }
            for swiftModule in swiftModules {
                let description = swiftModule.description
                let swiftModulePathWithoutDashAtTheEnd = description[..<description.index(before: description.endIndex)]
                _ = try shell(silent: "cp -r \(swiftModulePathWithoutDashAtTheEnd) \(output)")
            }
        }
    }
}
