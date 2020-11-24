//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension AllPackagesManager.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .podManager(state):
            return "pod: \(state.description)"
        case let .carthageManager(state):
            return "carthage: \(state.description)"
        case let .spmManager(state):
            return "spm: \(state.description)"
        }
    }
}
