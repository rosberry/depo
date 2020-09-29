//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class InstallCarthageItems: ParsableCommand {

    enum Error: LocalizedError {
        case badCartfile(path: String)
    }

    private enum CodingKeys: String, CodingKey {
        case options
        case carthageItems
    }

    static var configuration: CommandConfiguration = .init(commandName: "carthage-install")

    @OptionGroup()
    private(set) var options: Options
    private let cartFileName: String = AppConfiguration.cartFileName

    let carthageItems: [CarthageItem]?
    private let shell: Shell = .init()
    private lazy var carthageCommand: CarthageCommand = .init(shell: shell)

    init() {
        self.carthageItems = nil
    }

    init(carthageItems: [CarthageItem]) {
        self.carthageItems = carthageItems
    }

    func run() throws {
        let carthageItems = try self.carthageItems ?? Depofile(decoder: options.depoFileType.decoder).carts
        try createCartfile(at: "./\(cartFileName)", with: carthageItems)
        try carthageUpdate()
    }

    private func createCartfile(at cartfilePath: String, with items: [CarthageItem]) throws {
        let content = Cartfile(items: items).description.data(using: .utf8)
        if !FileManager.default.createFile(atPath: cartfilePath, contents: content) {
            throw Error.badCartfile(path: cartfilePath)
        }
    }

    private func carthageUpdate() throws {
        try carthageCommand.update(arguments: [.platformIOS])
    }
}
