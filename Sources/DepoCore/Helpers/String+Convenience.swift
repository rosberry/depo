//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public extension String {

    subscript(from index: Index) -> Substring {
        self[index..<self.index(startIndex, offsetBy: count)]
    }

    var words: [String] {
        split(separator: " ").map { substring in
            String(substring)
        }
    }

    var lines: [String] {
        split(separator: "\n").map { substring in
            String(substring)
        }
    }
}
