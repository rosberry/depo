//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class SwiftPackageCommand: ShellCommand {

    enum Error: LocalizedError {
        case badUpdate
    }

    func update() throws {
        if !shell("swift", "package", "update") {
            throw Error.badUpdate
        }
    }
}
