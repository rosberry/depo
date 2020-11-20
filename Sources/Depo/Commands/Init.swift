//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import Files
import DepoCore

final class Init: ParsableCommand {

    private enum State: CustomStringConvertible {
        var description: String {
            switch self {
            case .generatingEmptyDepofile:
                return "generating empty Depofile"
            case let .generatingDepofile(paths):
                let files = [paths.cartfilePath, paths.podfilePath, paths.packageSwiftFilePath].compactMap { $0 }
                return "generating Depofile from \(files.joined(separator: " "))"
            case .doneGeneratingDepofile:
                return "doneGeneratingDepofile"
            case .gettingBuildSettings:
                return "gettingBuildSettings"
            case .doneGettingBuildSettings:
                return "doneGettingBuildSettings"
            }
        }

        case generatingEmptyDepofile
        case generatingDepofile(paths: Action.Paths)
        case doneGeneratingDepofile
        case gettingBuildSettings
        case doneGettingBuildSettings

    }

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

    private lazy var shell: Shell = Shell().subscribe { state in
        switch state {
        case let .start(command):
            print(command.joined(separator: " "))
        }
    }
    private lazy var pod: PodShellCommand = .init(shell: shell)
    private lazy var swiftPackage: SwiftPackageShellCommand = .init(shell: shell)
    private lazy var carthage: CarthageShellCommand = .init(shell: shell)
    private let progress = DefaultProgressController<State>().subscribe { state in
        print(state)
    }

    func run() throws {
        try process(options: options)
    }

    private func process(options: Options) throws {
        let depofilePath = Depofile.defaultPath
        switch try action(for: options) {
        case .generateEmpty:
            progress.notify(.generatingEmptyDepofile)
            try generateEmptyDepofile(at: depofilePath)
            progress.notify(.doneGeneratingDepofile)
        case let .generateBy(paths):
            progress.notify(.gettingBuildSettings)
            let settings = try BuildSettings(shell: shell)
            progress.notify(.doneGettingBuildSettings)
            progress.notify(.generatingDepofile(paths: paths))
            try generateDepofile(at: depofilePath, by: paths, buildSettings: settings)
            progress.notify(.doneGeneratingDepofile)
        }
    }

    private func action(for options: Options) throws -> Action {
        guard let files = self.paths(from: options.filePaths) else {
            return .generateEmpty
        }
        return .generateBy(files)
    }

    private func generateEmptyDepofile(at path: String) throws {
        try create(depofile: .init(pods: [], carts: [], swiftPackages: []), at: path)
    }

    private func generateDepofile(at path: String, by paths: Action.Paths, buildSettings: BuildSettings) throws {
        let files = try self.files(from: paths, buildSettings: buildSettings)
        let depofile = Depofile(pods: files.podfile?.pods ?? [],
                                carts: files.cartfile?.items ?? [],
                                swiftPackages: files.packageSwiftFile?.packages ?? [])
        try create(depofile: depofile, at: path)
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

    private func create(depofile: Depofile, at path: String, ext: DataCoder.Kind = .defaultValue) throws {
        try Folder.current.createFile(at: path, contents: try ext.coder.encode(depofile))
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
