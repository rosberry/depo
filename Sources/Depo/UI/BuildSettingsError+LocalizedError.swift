//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension BuildSettings.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .badOutput(shellIO):
            return "cannot parse output of \(shellIO.command.spaceJoined)"
        case let .badBuildSettings(missedKey, shellIO):
            return "cannot find key \(missedKey) in output of \"\(shellIO.command.spaceJoined)\""
        }
    }
}
