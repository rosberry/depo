//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

final class CarthageManager: PackageManager {

    struct Options: HasDepofileExtension, ParsableArguments {
        @Option(name: [.customLong("depofile-extension"), .customShort(Character("e"))],
                help: "\(DataDecoder.Kind.allFlagsHelp)")
        var depofileExtension: DataDecoder.Kind = .defaultValue

        @Option(name: [.customLong("platform"), .customShort(Character("p"))],
                help: "\(CarthageShellCommand.Platform.allFlagsHelp)")
        var platform: CarthageShellCommand.Platform = .defaultValue
    }

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
    private let platform: CarthageShellCommand.Platform
    private let shell: Shell = .init()
    private lazy var carthageShellCommand: CarthageShellCommand = .init(shell: shell)

    convenience init(depofile: Depofile, options: Options) {
        self.init(depofile: depofile, platform: options.platform)
    }

    init(depofile: Depofile, platform: CarthageShellCommand.Platform) {
        self.carthageItems = depofile.carts
        self.platform = platform
    }

    func update() throws {
        try createCartfile(at: "./\(cartFileName)", with: carthageItems)
        try carthageShellCommand.update(arguments: [.platform(platform)])
    }

    func install() throws {
        try createCartfile(at: "./\(cartFileName)", with: carthageItems)
        try carthageShellCommand.bootstrap(arguments: [.platform(platform)])
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
