//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct Cartfile: CustomStringConvertible {
    let description: String

    init(items: [CarthageItem]) {
        self.description = items.map { item in
            "\(item.kind.rawValue) \"\(item.identifier)\"\(Self.carthageItemVersion(item))"
        }.joined(separator: "\n")
    }

    private static func carthageItemVersion(_ item: CarthageItem) -> String {
        item.version.map { version in
            switch version.operation {
            case .branchOrTagOrCommit:
                return " \"\(version.value)\""
            default:
                return " \(version.operation.symbol) \(version.value)"
            }
        } ?? ""
    }
}
