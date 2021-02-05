//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension CarthageManager.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .updating:
            return string("==> ", color: .cyan) + "Start updating carthage"
        case .installing:
            return string("==> ", color: .cyan) + "Start installing carthage"
        case .building:
            return string("==> ", color: .cyan) + "Start building carthage"
        case .downloadingSources:
            return ""
        case let .creatingCartfile(path):
            return "Creating cartfile at \(path)"
        case let .shell(state):
            return state.description
        }
    }
}

extension CarthageManager.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .badCartfile(path):
            return "unable to create Cartfile at \(path)"
        }
    }
}
