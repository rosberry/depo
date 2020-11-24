//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

extension String {

    subscript(from index: Index) -> Substring {
        self[index..<self.index(startIndex, offsetBy: count)]
    }
}