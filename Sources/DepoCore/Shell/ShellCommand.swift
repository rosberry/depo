//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public class ShellCommand: Codable {
    public let shell: Shell
    public let commandPath: String

    public init(commandPath: String, shell: Shell = .init()) {
        self.commandPath = commandPath
        self.shell = shell
    }
}
