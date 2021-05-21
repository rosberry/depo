//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore
import PathKit

final class LibA: ParsableCommand {

    @Option
    var scheme: String

    @Option
    var derivedDataPath: String?

    private let shell: Shell = Shell().subscribe { state in
        print(state)
    }
    private lazy var xcodebuild: XcodeBuild = .init(shell: shell)
    private lazy var lipo: Lipo = .init(shell: shell)

    func run() throws {
        let derivedDataPath = self.derivedDataPath ?? "\(scheme).derivedData"
        try build(scheme: scheme, derivedDataPath: derivedDataPath)
        let productPaths = Path.glob("\(derivedDataPath)/Build/Products/*")
        let libs = try productPaths.map { productPath in
            try makeStaticLibrary(productPath: productPath, name: "lib\(scheme).a")
        }
        let outputLibPath = Path("\(scheme).lib")
        let tmpLibPath = Path("\(derivedDataPath)/\(scheme).lib")

        try tmpLibPath.deleteIfExists()

        try makeFatStaticLibrary(smallLibs: libs, at: tmpLibPath)
        try collectSwiftModules(productPaths: productPaths, output: tmpLibPath)

        try tmpLibPath.overwrite(outputLibPath)
        print(outputLibPath)
    }

    private func build(scheme: String, derivedDataPath: String) throws {
        let simSettings = XcodeBuild.Settings.simulator(scheme: scheme,
                                                        derivedDataPath: derivedDataPath,
                                                        isSigning: false)
        let devSettings = XcodeBuild.Settings.device(scheme: scheme,
                                                     derivedDataPath: derivedDataPath,
                                                     isSigning: false)
        _ = try xcodebuild(settings: simSettings)
        _ = try xcodebuild(settings: devSettings)
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
