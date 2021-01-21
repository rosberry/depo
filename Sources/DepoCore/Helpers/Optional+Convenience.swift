//
// Copyright © 2021 Rosberry. All rights reserved.
//

extension Optional {
    var array: [Wrapped] {
        map { wrapped in
            [wrapped]
        } ?? []
    }
}
