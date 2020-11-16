//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class PodShellCommand: ShellCommand {

    public enum Error: LocalizedError {
        case badInit
        case badInstall
        case badUpdate
    }

    public func initialize() throws {
        if !shell("pod", "init") {
            throw Error.badInit
        }
    }

    public func install() throws {
        if !shell("pod", "install") {
            throw Error.badInstall
        }
    }

    public func update() throws {
        if !shell("pod", "update") {
            throw Error.badUpdate
        }
    }
}
