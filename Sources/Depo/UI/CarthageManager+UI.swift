//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension CarthageManager.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .updating:
            return "starts updating carthage"
        case .installing:
            return "starts installing carthage"
        case .building:
            return "starts building carthage"
        case let .creatingCartfile(path):
            return "creating cartfile at \(path)"
        }
    }
}
