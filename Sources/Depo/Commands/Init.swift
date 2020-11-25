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
                return "[1/1] generating empty Depofile"
            case let .generatingDepofile(paths):
                let files = [paths.cartfilePath, paths.podfilePath, paths.packageSwiftFilePath].compactMap { $0 }
                return "[1/1] generating Depofile from \(files.joined(separator: " "))"
            }
        }

        case generatingEmptyDepofile
        case generatingDepofile(paths: Action.Paths)
    }

    struct Options: ParsableArguments {

        @Argument(help: "use relative paths")
        var filePaths: [String] = []

        @Option()
        var podCommandPath: String = AppConfiguration.Path.Absolute.podCommandPath

        @Option()
        var carthageCommandPath: String = AppConfiguration.Path.Absolute.carthageCommandPath

        @Option()
        var swiftCommandPath: String = AppConfiguration.Path.Absolute.swiftCommandPath
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

    fileprivate struct Dependencies {
        let carthageItems: [CarthageItem]
        let pods: [Pod]
        let swiftPackages: [SwiftPackage]
    }

    @OptionGroup()
    var options: Options

    private lazy var shell: Shell = Shell().subscribe { state in
        switch state {
        case let .start(command):
            print(command.joined(separator: " "))
        }
    }
    private lazy var pod: PodShellCommand = .init(commandPath: options.podCommandPath, shell: shell)
    private lazy var swiftPackage: SwiftPackageShellCommand = .init(commandPath: options.swiftCommandPath, shell: shell)
    private lazy var carthage: CarthageShellCommand = .init(commandPath: options.carthageCommandPath, shell: shell)
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
        case let .generateBy(paths):
            progress.notify(.generatingDepofile(paths: paths))
            try generateDepofile(at: depofilePath, by: paths)
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

    private func generateDepofile(at path: String, by paths: Action.Paths) throws {
        let files = try self.files(from: paths)
        let depofile = Depofile(pods: files.pods,
                                carts: files.carthageItems,
                                swiftPackages: files.swiftPackages)
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

    private func files(from paths: Action.Paths) throws -> Dependencies {
        let carthageItems = try paths.cartfilePath.map { try carthage.cartfile(path: $0).items } ?? []
        let pods = try paths.podfilePath.map { try pod.pods(path: $0) } ?? []
        let swiftPackages = try paths.packageSwiftFilePath.map {
            try swiftPackage.swiftPackages(packageSwiftFilePath: $0)
        } ?? []
        return .init(carthageItems: carthageItems, pods: pods, swiftPackages: swiftPackages)
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
