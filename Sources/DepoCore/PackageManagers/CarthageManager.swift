//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class CarthageManager {

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
    private lazy var carthageShellCommand: CarthageShellCommand = .init(shell: shell)

    public init(depofile: Depofile, platform: Platform) {
        self.carthageItems = depofile.carts
        self.platform = platform
    }

    public func update() throws {
        try createCartfile(at: "./\(cartfileName)", with: carthageItems)
        try carthageShellCommand.update(arguments: [.platform(platform)])
    }

    public func install() throws {
        try createCartfile(at: "./\(cartfileName)", with: carthageItems)
        try carthageShellCommand.bootstrap(arguments: [.platform(platform)])
    }

    public func build() throws {
        try carthageShellCommand.build()
    }

    private func createCartfile(at cartfilePath: String, with items: [CarthageItem]) throws {
        let content = Cartfile(items: items).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: cartfilePath, contents: content) {
            throw Error.badCartfile(path: cartfilePath)
        }
    }
}
