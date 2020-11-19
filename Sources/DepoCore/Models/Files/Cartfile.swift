//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct Cartfile: CustomStringConvertible {
    public let description: String

    public init(items: [CarthageItem]) {
        description = items.reduce("") { result, item in
            result + "\(item)\n"
        }
    }
}
