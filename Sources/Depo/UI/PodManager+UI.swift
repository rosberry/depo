//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension PodManager.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .installing:
            return "installing"
        case .updating:
            return "updating"
        case .building:
            return "building"
        case .processing:
            return "processing"
        case let .creatingPodfile(path):
            return "creating podfile at \(path)"
        case let .buildingPod(pod):
            return "building pod \(pod.name)"
        case let .processingPod(pod):
            return "processing pod \(pod.name)"
        }
    }
}
