//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

public struct CarthageItem: Codable {

    private enum CodingKeys: String, CodingKey {
        case kind
        case identifier
        case versionConstraint = "version"
    }

    enum Kind: String, Codable {
        case binary
        case github
        case git
    }

    enum Operator: String, Codable, HasDefaultValue {
        case equal
        case compatible
        case greaterOrEqual
        case branchOrTagOrCommit

        var symbol: String {
            switch self {
            case .equal:
                return "=="
            case .greaterOrEqual:
                return ">="
            case .compatible:
                return "~>"
            case .branchOrTagOrCommit:
                return ""
            }
        }
        static let defaultValue: Operator = .equal
    }

    let kind: Kind
    let identifier: String
    let versionConstraint: VersionConstraint<Operator>?
}
