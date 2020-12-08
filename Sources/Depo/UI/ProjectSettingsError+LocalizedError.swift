//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension ProjectSettings.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .badOutput(io):
            return "cannot parse output of \(io.command.spaceJoined)"
        }
    }
}