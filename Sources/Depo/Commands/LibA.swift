//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser
import DepoCore
import PathKit

final class LibA: ParsableCommand {

    static let configuration: CommandConfiguration = .init(commandName: "liba",
                                                               abstract: "build static library fro swift project")

    @Option
    var scheme: String

    @Option
    var derivedDataPath: String?

    private let shell: Shell = Shell().subscribe { state in
        print(state)
    }

    func run() throws {
        let service = StaticLibraryBuilderService()
        service.subscribe { state in
            print(state)
        }
        let derivedDataPath = self.derivedDataPath ?? "\(scheme).derivedData"
        let libPath = try service.build(scheme: scheme, derivedDataPath: derivedDataPath)
        print("Done building \(string(libPath, color: .green))")
    }
}
