//
// Copyright © 2021 Rosberry. All rights reserved.
//

extension Bool {
    func mapTrue<T>(to value: T) -> T? {
        self ? value : nil
    }
}
