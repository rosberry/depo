//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

class ShellCommand: Codable {
    let shell: Shell

    init(shell: Shell = .init()) {
        self.shell = shell
    }
}
