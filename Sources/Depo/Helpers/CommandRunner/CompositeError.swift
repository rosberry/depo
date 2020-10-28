//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct CompositeError: LocalizedError {

    let errors: [Error]

    init(errors: [Error]) {
        self.errors = errors
    }
}