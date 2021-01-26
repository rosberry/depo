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
        case .processing:
            return string("==> ", color: .cyan) + "Processing pods"
        case let .creatingPodfile(path):
            return "Creating Podfile at \(path)"
        case let .buildingPod(pod, kind, buildPath):
            return "Building \(string(pod.name, color: .magenta)) at \(buildPath)"
        case let .processingPod(pod):
            return "Processing \(string(pod.name, color: .magenta))"
        case let .making(kind, pod, outputPath):
            return "Making \(kind) from \(pod.name) -> \(outputPath)"
        case let .movingPod(pod, outputPath):
            return "Moving built \(pod.name) to \(outputPath)"
        case let .doneBuilding(pod):
            return "Done building \(string(pod.name, color: .green))\n"
        case let .doneProcessing(pod):
            return "Done processing \(string(pod.name, color: .green))\n"
        case let .buildingFailed(pod):
            return "Got error while building \(string(pod.name, color: .red))\n"
        case let .processingFailed(pod):
            return "Got error while processing \(string(pod.name, color: .red))\n"
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
