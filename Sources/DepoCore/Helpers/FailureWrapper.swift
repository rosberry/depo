//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

public struct FailureWrapper<Value, E: Swift.Error>: Error {

    public let error: E
    public let value: Value

    public var localizedDescription: String {
        error.localizedDescription
    }

    init(error: E, value: Value) {
        self.error = error
        self.value = value
    }
}

extension FailureWrapper: LocalizedError where E: LocalizedError {

    public var errorDescription: String? {
        error.errorDescription
    }
}
