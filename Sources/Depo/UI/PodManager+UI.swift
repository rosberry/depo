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
        case let .movingPod(from, to):
            return "\(from) -> \(to)"
        case let .shell(state):
            return state.description
        }
    }
}

extension PodManager.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .badPodfile(path):
            return "bad Podfile at \(path)"
        case let .badPodBuild(contexts):
            return """
                   bad pod build:
                   \(contexts.map { (error, pod) in "\(error.localizedDescription) for \(pod.name)" }.newLineJoined)
                   """
        case let .badPodMerge(contexts):
            return """
                   bad pod merge:
                   \(contexts.map { (error, pod) in "\(error.localizedDescription) for \(pod.name)" }.newLineJoined)
                   """
        }
    }
}
