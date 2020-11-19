//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import Files
import DepoCore

final class Init: ParsableCommand {

    struct Options: ParsableArguments {

        @Argument(help: "use relative paths")
        var filePaths: [String] = []
    }

    fileprivate enum Action {

        struct Paths {

            typealias FieldContext = (keyPath: WritableKeyPath<Self, String?>, value: String)

            var cartfilePath: String?
            var podfilePath: String?
            var packageSwiftFilePath: String?

            static let fileNames: [FieldContext] = {
                [(\.cartfilePath, AppConfiguration.Name.cartfile),
                 (\.podfilePath, AppConfiguration.Name.podfile),
                 (\.packageSwiftFilePath, AppConfiguration.Name.packageSwift)]
            }()
        }

        case generateEmpty
        case generateBy(Paths)
    }

    fileprivate struct Files {
        let cartfile: Cartfile?
        let podfile: PodFile?
        let packageSwiftFile: PackageSwift?
    }

    @OptionGroup()
    var options: Options

    private let shell: Shell = .init()
    private let pod: PodShellCommand = .init()
    private let swiftPackage: SwiftPackageShellCommand = .init()
    private let carthage: CarthageShellCommand = .init()

    func run() throws {
        switch try action(for: options) {
        case .generateEmpty:
            try generateEmptyDepofile()
        case let .generateBy(files):
            let settings = try BuildSettings()
            try generateDepofile(by: files, buildSettings: settings)
        }
    }

    private func action(for options: Options) throws -> Action {
        guard let files = self.paths(from: options.filePaths) else {
            return .generateEmpty
        }
        return .generateBy(files)
    }

    private func generateEmptyDepofile() throws {
        try create(depofile: .init(pods: [], carts: [], swiftPackages: []))
    }

    private func generateDepofile(by paths: Action.Paths, buildSettings: BuildSettings) throws {
        let files = try self.files(from: paths, buildSettings: buildSettings)
        let depofile = Depofile(pods: files.podfile?.pods ?? [],
                                carts: files.cartfile?.items ?? [],
                                swiftPackages: files.packageSwiftFile?.packages ?? [])
        try create(depofile: depofile)
    }

    private func paths(from paths: [String]) -> Action.Paths? {
        guard !paths.isEmpty else {
            return nil
        }
        let paths: [Init.Action.Paths.FieldContext] = options.filePaths.compactMap { path in
            guard let url = URL(string: path),
                  let keyPath = Action.Paths.fileNames.first(with: url.lastPathComponent, at: \.value)?.keyPath else {
                return nil
            }
            return (keyPath, path)
        }
        return Action.Paths(fields: paths)
    }

    private func files(from paths: Action.Paths, buildSettings: BuildSettings) throws -> Files {
        let cartfile = try paths.cartfilePath.map { try carthage.cartfile(path: $0) }
        let podfile = try paths.podfilePath.map { try pod.podfile(buildSettings: buildSettings, path: $0) }
        let packageSwift = try paths.packageSwiftFilePath.map { try swiftPackage.packageSwift(buildSettings: buildSettings, path: $0) }
        return .init(cartfile: cartfile, podfile: podfile, packageSwiftFile: packageSwift)
    }

    private func create(depofile: Depofile, ext: DataCoder.Kind = .defaultValue) throws {
        try Folder.current.createFile(at: Depofile.defaultPath, contents: try ext.coder.encode(depofile))
    }
}

fileprivate extension Init.Action.Paths {
    init(fields: [FieldContext]) {
        var this = Self()
        fields.forEach { (keyPath, value) in
            this[keyPath: keyPath] = value
        }
        self = this
    }
}
