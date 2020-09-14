//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import ArgumentParser

struct CarthageItem: Codable {

    enum Kind: String, Codable {
        case binary
        case github
        case git
    }

    enum Operator: String, Codable, HasDefault {
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
    let version: Version<Operator>?
}