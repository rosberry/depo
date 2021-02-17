//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension Shell.Error: LocalizedError {
    public var errorDescription: String? {
        description
    }
}

extension Shell.Error: CustomStringConvertible {
    public var description: String {
        return """
               Shell encountered an error
               Status code: \(terminationStatus)
               Message: "\(message ?? "")"
               Output: "\(output ?? "")"
               """
    }
}

extension Shell.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .start(command, callKind):
            return description(of: command, callKind: callKind)
        }
    }

    private func description(of command: String, callKind: Shell.CallKind) -> String {
        "> \(command)"
    }
}
