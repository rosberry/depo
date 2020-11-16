//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct Cartfile: CustomStringConvertible {
    public let description: String

    public init(items: [CarthageItem]) {
        description = items.reduce("") { result, item in
            result + "\(item.kind.rawValue) \"\(item.identifier)\"\(Self.carthageItemVersion(item))\n"
        }
    }

    private static func carthageItemVersion(_ item: CarthageItem) -> String {
        guard let versionConstraint = item.versionConstraint else {
            return ""
        }
        switch versionConstraint.operation {
        case .branchOrTagOrCommit:
            return " \"\(versionConstraint.value)\""
        default:
            return " \(versionConstraint.operation.symbol) \(versionConstraint.value)"
        }
    }
}
