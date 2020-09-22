//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class InstallCarthageItems: ParsableCommand {

    enum Error: LocalizedError {
        case badCartfile(path: String)
        case badCarthageUpdate
    }

    static var configuration: CommandConfiguration = .init(commandName: "carthage-install")

    @OptionGroup()
    private(set) var options: Options
    private let cartFileName: String = AppConfiguration.cartFileName

    let carthageItems: [CarthageItem]?
    private let shell: Shell = .init()

    init() {
        self.carthageItems = nil
    }

    init(carthageItems: [CarthageItem]) {
        self.carthageItems = carthageItems
    }

    func run() throws {
        let carthageItems = try self.carthageItems ?? CarPodfile(decoder: options.carpodFileType.decoder).carts
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
        if shell("carthage", "update", "--platform", "ios") != 0 {
            throw Error.badCarthageUpdate
        }
    }
}
