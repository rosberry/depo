//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class CarthageManager: ProgressObservable, HasAllCommands {

    public typealias Packages = [CarthageItem]
    public enum State {
        case updating
        case installing
        case building
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

    public let outputPath: String = "Carthage/Build/iOS"
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

    public func update(packages: Packages) throws {
        observer?(.updating)
        try createCartfile(at: "./\(cartfileName)", with: packages)
        try carthageShellCommand.update(arguments: carthageArgs)
    }

    public func install(packages: Packages) throws {
        observer?(.installing)
        try createCartfile(at: "./\(cartfileName)", with: packages)
        try carthageShellCommand.bootstrap(arguments: carthageArgs)
    }

    public func build(packages: Packages) throws {
        observer?(.building)
        try carthageShellCommand.build(arguments: carthageArgs)
    }

    private func createCartfile(at cartfilePath: String, with items: [CarthageItem]) throws {
        observer?(.creatingCartfile(path: cartfilePath))
        let content = Cartfile(items: items).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: cartfilePath, contents: content) {
            throw Error.badCartfile(path: cartfilePath)
        }
    }
}
