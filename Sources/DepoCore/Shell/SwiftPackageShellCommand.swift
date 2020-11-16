//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class SwiftPackageShellCommand: ShellCommand {

    public enum Error: LocalizedError {
        case badUpdate
    }

    public func update() throws {
        if !shell("swift", "package", "update") {
            throw Error.badUpdate
        }
    }
}
