//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore
import PathKit

final class LibA: ParsableCommand {

    static let configuration: CommandConfiguration = .init(commandName: "liba",
                                                           abstract: "build static library from swift project")

    @Option(completion: .file())
    var swiftCommandPath: String = AppConfiguration.Path.Absolute.swiftCommandPath

    @Option
    var scheme: String

    @Option
    var derivedDataPath: String?

    private let shell: Shell = Shell().subscribe { state in
        print(state)
    }

    func run() throws {
        let service = StaticLibraryBuilderService(swiftCommandPath: swiftCommandPath)
        service.subscribe { state in
            print(state)
        }
        let libPath = try service.build(scheme: scheme, derivedDataPath: derivedDataPath)
        print("Done building \(string(libPath, color: .green))")
    }
}
