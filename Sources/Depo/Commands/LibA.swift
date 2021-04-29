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
    var derivedDataPath: String

    private let shell: Shell = Shell().subscribe { state in
        print(state)
    }
    private lazy var xcodebuild: XcodeBuild = .init(shell: shell)
    private lazy var lipo: Lipo = .init(shell: shell)

    func run() throws {
        try build(scheme: scheme)
        let productPaths = Path.glob("\(derivedDataPath)/Build/Products/*")
        let libs = try productPaths.map { productPath in
            try makeStaticLibrary(productPath: productPath, name: "lib\(scheme).a")
        }
        let fatLib = try makeFatStaticLibrary(smallLibs: libs, name: "\(scheme).lib")
        try collectSwiftModules(productPaths: productPaths, output: fatLib)
        print(fatLib)
    }

    private func build(scheme: String) throws {
        let simSettings = XcodeBuild.Settings.simulator(scheme: scheme,
                                                        derivedDataPath: derivedDataPath,
                                                        isSigning: false)
        let devSettings = XcodeBuild.Settings.device(scheme: scheme,
                                                     derivedDataPath: derivedDataPath,
                                                     isSigning: false)
        _ = try xcodebuild.buildForDistribution(settings: simSettings)
        _ = try xcodebuild.buildForDistribution(settings: devSettings)
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

    private func makeFatStaticLibrary(smallLibs: [Path], name: String) throws -> Path {
        guard let firstSmallLib = smallLibs.first else {
            throw FatStaticLibError.emptySmallLibs
        }
        let libPath = Path("./\(name)")
        try libPath.mkdir()
        let outputPath = "\(libPath)/\(firstSmallLib.lastComponent)"
        let executables = smallLibs.map(by: \.description)
        try lipo(.create, outputPath, executables)
        return libPath
    }

    private func collectSwiftModules(productPaths: [Path], output: Path) throws {
        for productPath in productPaths {
            let swiftModules = productPath.glob("*.swiftmodule")
            for swiftModule in swiftModules {
                let description = swiftModule.description
                let swiftModulePathWithoutDashAtTheEnd = description[..<description.index(before: description.endIndex)]
                _ = try shell(silent: "cp -r \(swiftModulePathWithoutDashAtTheEnd) \(output)")
            }
        }
    }
}

class Builder {

}

extension Path {
    var folder: Path? {
        guard !isDirectory else {
            return nil
        }
        var output = description
        output.removeLast(lastComponent.count)
        return Path(output)
    }
}