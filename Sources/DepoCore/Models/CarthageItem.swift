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

    public enum Kind: String, Codable {
        case binary
        case github
        case git
    }

    public enum Operator: String, Codable, HasDefaultValue {
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
        public static let defaultValue: Operator = .equal
    }

    public let kind: Kind
    public let identifier: String
    public let versionConstraint: VersionConstraint<Operator>?
}
