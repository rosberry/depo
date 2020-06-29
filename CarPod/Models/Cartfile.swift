//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
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
        if let version = item.version {
            if version.isOptimistic {
                return " ~> \(version.value)"
            }
            else {
                return " \(version.value)"
            }
        }
        else {
            return ""
        }
    }
}
