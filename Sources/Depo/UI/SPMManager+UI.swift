//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension SPMManager.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .updating:
            return string("==> ", color: .cyan) + "Updating swift packages"
        case .building:
            return string("==> ", color: .cyan) + "Building swift packages"
        case let .buildingPackage(package, path):
            return "Building \(string(package.name, color: .magenta)) at \(path)"
        case let .merging(framework, kind, outputPath):
            return "Making \(kind.description) from \(framework) -> \(outputPath)"
        case let .done(package):
            return "Done with \(string(package.name, color: .green))\n"
        case let .creatingPackageSwiftFile(path):
            return "Creating Package.swift at \(path)"
        case let .shell(state):
            return state.description
        case let .merge(state):
            return state.description
        }
    }
}

extension SPMManager.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .badPackageSwiftFile(path):
            return "bad Package.swift at \(path)"
        case let .badSwiftPackageBuild(contexts):
            return """
                   bad swift package build:
                   \(contexts.map { (error, package) in "\(error.localizedDescription) for \(package.name)" }.newLineJoined)
                   """
        case .noDevelopmentTeam:
            return "development team is required for building swift packages"
        case let .noSchemaToBuild(package):
            return "no schema found for \(package.name)"
        }
    }
}
