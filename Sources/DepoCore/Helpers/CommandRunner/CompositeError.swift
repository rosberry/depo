//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct CompositeError: Error {

    public let errors: [Error]

    init(errors: [Error]) {
        self.errors = errors
    }
}