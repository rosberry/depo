//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension BuildSettings.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .badOutput(io):
            return "cannot parse output of \(io.command.spaceJoined)"
        case let .badBuildSettings(missedKey, io):
            return "cannot find key \(missedKey) in output of \"\(io.command.spaceJoined)\""
        }
    }
}
