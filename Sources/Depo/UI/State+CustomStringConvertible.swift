//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension AllPackagesManager.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .podManager(state):
            return state.description
        case let .carthageManager(state):
            return state.description
        case let .spmManager(state):
            return state.description
        }
    }
}

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

extension PodManager.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .installing:
            return "\(Self.self): installing"
        case .updating:
            return "\(Self.self): updating"
        case .building:
            return "\(Self.self): building"
        }
    }
}

extension SPMManager.State: CustomStringConvertible {
    public var description: String {
        "\(Self.self)"
    }
}
