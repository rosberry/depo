//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension SPMManager.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .updating:
            return "updating"
        case .building:
            return "building"
        case let .buildingPackage(package, path):
            return "building package \(package.name) at \(path)"
        case .processing:
            return "processing"
        case let .processingPackage(package, path):
            return "processing package \(package.name) at \(path)"
        case let .creatingPackageSwiftFile(path):
            return "creation Package.swift at \(path)"
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
        case let .badSwiftPackageProceed(contexts):
            return """
                   bad proceeding of swift packages:
                   \(contexts.map { (error, package) in "\(error.localizedDescription) for \(package.name)" }.newLineJoined)
                   """
        case .noDevelopmentTeam:
            return "development team is required for building swift packages"
        case let .noSchemaToBuild(package):
            return "no schema found for \(package.name)"
        }
    }
}
