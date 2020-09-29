//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class PodCommand: ShellCommand {

    enum Error: LocalizedError {
        case badInit
        case badInstall
    }

    func initialize() throws {
        if !shell("pod", "init") {
            throw Error.badInit
        }
    }

    func install() throws {
        if !shell("pod", "install") {
            throw Error.badInstall
        }
    }
}
