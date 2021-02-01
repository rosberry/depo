//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class CarthageManager: ProgressObservable, HasAllCommands {

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

    private let carthageItems: [CarthageItem]
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

    public init(carthageItems: [CarthageItem], platform: Platform, carthageCommandPath: String, cacheBuilds: Bool, carthageArguments: String?) {
        self.carthageItems = carthageItems
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

    public func update() throws {
        observer?(.updating)
        try createCartfile(at: "./\(cartfileName)", with: carthageItems)
        try carthageShellCommand.update(arguments: carthageArgs)
    }

    public func install() throws {
        observer?(.installing)
        try createCartfile(at: "./\(cartfileName)", with: carthageItems)
        try carthageShellCommand.bootstrap(arguments: carthageArgs)
    }

    public func build() throws {
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
