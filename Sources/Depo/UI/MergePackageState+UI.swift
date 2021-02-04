//
// Copyright © 2020 Rosberry. All rights reserved.
//

import DepoCore

extension MergePackage.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .makingSP(name, kind, outputPath):
            return "merging swift package \(name) like \(kind)"
        case let .makingPod(name, kind, outputPath):
            return "merging pod \(name) like \(kind)"
        }
    }
}
