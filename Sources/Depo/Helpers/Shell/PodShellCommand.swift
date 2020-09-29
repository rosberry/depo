//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class PodShellCommand: ShellCommand {

    enum Error: LocalizedError {
        case badInit
        case badInstall
        case badUpdate
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

    func update() throws {
        if !shell("pod", "update") {
            throw Error.badUpdate
        }
    }
}
