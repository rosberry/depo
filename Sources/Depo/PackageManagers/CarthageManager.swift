//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class CarthageManager: PackageManager {

    enum Error: LocalizedError {
        case badCartfile(path: String)
    }

    private enum CodingKeys: String, CodingKey {
        case options
        case carthageItems
    }

    static var configuration: CommandConfiguration = .init(commandName: "carthage-install")

    private let cartFileName: String = AppConfiguration.cartFileName

    private let carthageItems: [CarthageItem]
    private let shell: Shell = .init()
    private lazy var carthageShellCommand: CarthageShellCommand = .init(shell: shell)

    init(depofile: Depofile) {
        self.carthageItems = depofile.carts
    }

    func update() throws {
        try createCartfile(at: "./\(cartFileName)", with: carthageItems)
        try carthageShellCommand.update(arguments: [.platform(.ios)])
    }

    func install() throws {
        try createCartfile(at: "./\(cartFileName)", with: carthageItems)
        try carthageShellCommand.bootstrap(arguments: [.platform(.ios)])
    }

    func build() throws {
        try carthageShellCommand.build()
    }

    private func createCartfile(at cartfilePath: String, with items: [CarthageItem]) throws {
        let content = Cartfile(items: items).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: cartfilePath, contents: content) {
            throw Error.badCartfile(path: cartfilePath)
        }
    }
}
