//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class PodCommand: Codable {

    enum Error: LocalizedError {
        case badPodInit
        case badPodInstal
    }

    private let shell: Shell

    init(shell: Shell = .init()) {
        self.shell = shell
    }

    func initialize() throws {
        if !shell("pod", "init") {
            throw Error.badPodInit
        }
    }

    func install() throws {
        if !shell("pod", "install") {
            throw Error.badPodInit
        }
    }
}
