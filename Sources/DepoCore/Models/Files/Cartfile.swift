//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct Cartfile: CustomStringConvertible {
    public let description: String
    public let items: [CarthageItem]

    public init(items: [CarthageItem]) {
        self.items = items
        description = items.reduce("") { result, item in
            result + "\(item)\n"
        }
    }
}
