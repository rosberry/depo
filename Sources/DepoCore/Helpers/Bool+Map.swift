//
// Copyright © 2021 Rosberry. All rights reserved.
//

extension Bool {
    func mapTrue<T>(to value: T) -> T? {
        if self {
            return value
        }
        else {
            return nil
        }
    }
}
