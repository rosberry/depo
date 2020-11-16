//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public class ShellCommand: Codable {
    public let shell: Shell

    public init(shell: Shell = .init()) {
        self.shell = shell
    }
}
