//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import PathKit

public final class CarthageManager: ProgressObservable, HasAllCommands {

    public typealias Package = CarthageItem
    public typealias BuildResult = PackageOutput<Package>

    public enum State {
        case updating
        case installing
        case building
        case downloadingSources
        case creatingCartfile(path: String)
        case shell(state: Shell.State)
    }

    public enum Error: Swift.Error {
        case badCartfile(path: String)
    }

    private enum CodingKeys: String, CodingKey {
        case options
        case carthageItems
    }

    private let cartfileName: String = AppConfiguration.Name.cartfile
    private let carthageBuildPath: String = AppConfiguration.Path.Relative.carthageBuildDirectory
    private var carthageBackupBuildPath: String {
        self.carthageBuildPath + ".bak"
    }

    public let outputPath: String = AppConfiguration.Path.Relative.carthageIosBuildDirectory
    private let platform: Platform
    private let shell: Shell = .init()
    private let carthageShellCommand: CarthageShellCommand
    private var observer: ((State) -> Void)?
    private let cacheBuilds: Bool
    private let carthageArguments: String?
    private var carthageArgs: [CarthageShellCommand.BuildArgument] {
        let cacheBuilds = self.cacheBuilds.mapTrue(to: CarthageShellCommand.BuildArgument.cacheBuilds).array
        return cacheBuilds + [.platform(platform), .custom(args: carthageArguments ?? "")]
    }

    public init(platform: Platform,
                carthageCommandPath: String,
                cacheBuilds: Bool,
                carthageArguments: String?) {
        self.platform = platform
        self.carthageShellCommand = .init(commandPath: carthageCommandPath, shell: shell)
        self.cacheBuilds = cacheBuilds
        self.carthageArguments = carthageArguments
        self.shell.subscribe { [weak self] state in
            self?.observer?(.shell(state: state))
        }
    }

    public func subscribe(_ observer: @escaping (State) -> Void) -> Self {
        self.observer = observer
        return self
    }

    public func update(packages: [Package]) throws -> [BuildResult] {
        observer?(.updating)
        try createCartfile(at: "./\(cartfileName)", with: packages)
        try carthageShellCommand.update(arguments: carthageArgs)
        return []
    }

    public func install(packages: [Package]) throws -> [BuildResult] {
        observer?(.installing)
        try createCartfile(at: "./\(cartfileName)", with: packages)
        try carthageShellCommand.bootstrap(arguments: carthageArgs)
        return []
    }

    public func build(packages: [Package]) throws -> [BuildResult] {
        observer?(.building)
        try carthageShellCommand.build(arguments: carthageArgs)
        return []
    }

    private func createCartfile(at cartfilePath: String, with items: [CarthageItem]) throws {
        observer?(.creatingCartfile(path: cartfilePath))
        let content = Cartfile(items: items).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: cartfilePath, contents: content) {
            throw Error.badCartfile(path: cartfilePath)
        }
    }

    private func buildForGitCachablePackageManager(packages: [Package]) throws -> [BuildResult] {
        renameOldCarthageBuildIfExists()
        for package in packages where package.kind == .github {
            let packageArg = package.identifier.split(separator: " ")
            try carthageShellCommand.build(arguments: carthageArgs + [.custom(args: package.identifier)])
        }
        return []
    }

    private func updateSources() throws {
        observer?(.downloadingSources)
        try carthageShellCommand.update(arguments: [.custom(args: "--no-build")])
    }

    private func bootstrapSources() throws {
        observer?(.downloadingSources)
        try carthageShellCommand.bootstrap(arguments: [.custom(args: "--no-build")])
    }

    private func renameOldCarthageBuildIfExists() {
        let carthageBuildDir = Path(carthageBuildPath)
        try? carthageBuildDir.move(Path(carthageBackupBuildPath))
    }
}
