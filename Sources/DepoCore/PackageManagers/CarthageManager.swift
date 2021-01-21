//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class CarthageManager: ProgressObservable {

    public enum State {
        case updating
        case installing
        case building
        case creatingCartfile(path: String)
        case shell(state: Shell.State)
    }

    public enum Error: LocalizedError {
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
        [.platform(platform)] + cacheBuilds.mapTrue(to: CarthageShellCommand.BuildArgument.cacheBuilds).array
    }

    public init(depofile: Depofile, platform: Platform, carthageCommandPath: String, cacheBuilds: Bool, carthageArguments: String?) {
        self.carthageItems = depofile.carts
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
        try carthageShellCommand.build()
    }

    private func createCartfile(at cartfilePath: String, with items: [CarthageItem]) throws {
        observer?(.creatingCartfile(path: cartfilePath))
        let content = Cartfile(items: items).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: cartfilePath, contents: content) {
            throw Error.badCartfile(path: cartfilePath)
        }
        var t: Int? = 1
    }
}

extension Bool {
    func mapTrue<T>(to value: T) -> T? {
        if self {
            return value
        }
        else {
            return nil
        }
    }
}

extension Optional {
    var array: [Wrapped] {
        map { wrapped in
            [wrapped]
        } ?? []
    }
}