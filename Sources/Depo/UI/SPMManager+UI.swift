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
        }
    }
}
