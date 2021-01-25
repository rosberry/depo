//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension PodManager.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .installing:
            return string("==> ", color: .cyan) + "Installing pods"
        case .updating:
            return string("==> ", color: .cyan) + "Updating pods"
        case .building:
            return string("==> ", color: .cyan) + "Building pods"
        case let .creatingPodfile(path):
            return "Creating Podfile at \(path)"
        case let .buildingPod(pod, kind, buildPath):
            return "Building \(string(pod.name, color: .magenta)) at \(buildPath)"
        case let .processingPod(pod, kind, outputPath):
            return "Making \(kind) from \(string(pod.name, color: .magenta)) -> \(outputPath)"
        case let .movingPod(from, to):
            return "\(from) -> \(to)"
        case let .doneBuilding(pod):
            return "Done building \(string(pod.name, color: .green))\n"
        case let .doneProcessing(pod, kind):
            return "\(kind) is made from \(string(pod.name, color: .green))\n"
        case let .buildingFailed(pod):
            return "Got error while building \(string(pod.name, color: .red))\n"
        case let .processingFailed(pod, kind):
            return "Got error while making \(kind) from \(string(pod.name, color: .red))\n"
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
        case .noTargetsToBuild:
            return "project has no targets to build"
        }
    }
}
