//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension Shell.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .failure(io):
            return "\(io)"
        }
    }
}

extension Shell.IO: CustomStringConvertible {
    public var description: String {
        "\(self.command.joined(separator: " ")) exits with \(self.status) status code" +
        fileDescriptorsDescription
    }

    private var fileDescriptorsDescription: String {
        (self.stdOut.isEmpty ? "" : "\nstdOut: \(stdOut)") +
        (self.stdIn.isEmpty ? "" : "\nstdIn: \(stdIn)") +
        (self.stdErr.isEmpty ? "" : "\nstdErr: \(stdErr)")
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
