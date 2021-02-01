//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import DepoCore
import ArgumentParser

final class Example: ParsableCommand {
    static let configuration: CommandConfiguration = .init(commandName: "example",
                                                           abstract: "prints example of Depofile")

    private lazy var shell: Shell = Shell()

    func run() throws {
        let exampleURL = "https://raw.githubusercontent.com/rosberry/depo/master/DepofileExample.yaml"
        let output = try shell(silent: "curl \(exampleURL)")
        print(output.stdOut)
    }
}
