//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public extension Array where Element == String {
    var spaceJoined: String {
        joined(separator: " ")
    }

    var newLineJoined: String {
        joined(separator: "\n")
    }
}
