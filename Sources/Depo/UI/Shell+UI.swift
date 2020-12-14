//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension Shell.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .failure(shellIO):
            return "\(shellIO)"
        }
    }
}

extension Shell.IO: CustomStringConvertible {
    public var description: String {
        "\(command.spaceJoined) exits with \(status) status code" +
        fileDescriptorsDescription
    }

    private var fileDescriptorsDescription: String {
        (stdOut.isEmpty ? "" : "\nstdOut: \n\(stdOut)") +
        (stdIn.isEmpty ? "" : "\nstdIn: \n\(stdIn)") +
        (stdErr.isEmpty ? "" : "\nstdErr: \n\(stdErr)")
    }
}

extension Shell.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .start(command):
            return command.spaceJoined
        }
    }
}
