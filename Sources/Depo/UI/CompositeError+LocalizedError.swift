//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation
import DepoCore

extension CompositeError: LocalizedError {
    public var errorDescription: String? {
        errors.map { $0.localizedDescription }.newLineJoined
    }
}
