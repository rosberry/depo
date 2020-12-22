//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class InitService: ProgressObservable {

    public enum State {
        case generatingEmptyDepofile
        case generatingDepofile(paths: Action.Paths)
        case shell(state: Shell.State)
    }

    public enum Action {

        public struct Paths {

            typealias FieldContext = (keyPath: WritableKeyPath<Self, String?>, value: String)

            public var cartfilePath: String?
            public var podfilePath: String?
            public var packageSwiftFilePath: String?

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

    private var observer: ((State) -> Void)?
    private let shell: Shell
    private let pod: PodShellCommand
    private let swiftPackage: SwiftPackageShellCommand
    private let carthage: CarthageShellCommand

    public init(podCommandPath: String,
                carthageCommandPath: String,
                swiftCommandPath: String) {
        let shell = Shell()
        self.shell = shell
        pod = .init(commandPath: podCommandPath, shell: shell)
        swiftPackage = .init(commandPath: swiftCommandPath, shell: shell)
        carthage = .init(commandPath: carthageCommandPath, shell: shell)
        shell.subscribe { [weak self] state in
            self?.observer?(.shell(state: state))
        }
    }

    @discardableResult
    public func subscribe(_ observer: @escaping (State) -> Void) -> Self {
        self.observer = observer
        return self
    }

    public func process(filePaths: [String]) throws {
        let depofilePath = Depofile.defaultPath
        switch try action(for: filePaths) {
        case .generateEmpty:
            observer?(.generatingEmptyDepofile)
            try generateEmptyDepofile(at: depofilePath)
        case let .generateBy(paths):
            observer?(.generatingDepofile(paths: paths))
            try generateDepofile(at: depofilePath, by: paths)
        }
    }

    private func action(for filePaths: [String]) throws -> Action {
        guard let files = self.paths(from: filePaths) else {
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
        let paths: [Action.Paths.FieldContext] = paths.compactMap { path in
            guard let url = URL(string: path),
                  let keyPath = Action.Paths.fileNames.first(with: url.lastPathComponent, at: \.value)?.keyPath else {
                return nil
            }
            return (keyPath, path)
        }
        return Action.Paths(fields: paths)
    }

    private func files(from paths: Action.Paths) throws -> Dependencies {
        let carthageItems = try paths.cartfilePath.map { path in
            try carthage.cartfile(cartfilePath: path).items
        } ?? []
        let pods = try paths.podfilePath.map { path in
            try pod.pods(podfilePath: path)
        } ?? []
        let swiftPackages = try paths.packageSwiftFilePath.map { path in
            try swiftPackage.swiftPackages(packageSwiftFilePath: path)
        } ?? []
        return .init(carthageItems: carthageItems, pods: pods, swiftPackages: swiftPackages)
    }

    private func create(depofile: Depofile, at path: String, ext: DataCoder.Kind = .defaultValue) throws {
        try Folder.current.createFile(at: path, contents: try ext.coder.encode(depofile))
    }
}

fileprivate extension InitService.Action.Paths {
    init(fields: [FieldContext]) {
        var this = Self()
        fields.forEach { (keyPath, value) in
            this[keyPath: keyPath] = value
        }
        self = this
    }
}
