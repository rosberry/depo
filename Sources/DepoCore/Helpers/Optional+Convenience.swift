//
// Copyright © 2021 Rosberry. All rights reserved.
//

public extension Optional {
    var array: [Wrapped] {
        map { wrapped in
            [wrapped]
        } ?? []
    }

    func mapOrDefault<T: HasDefaultValue>(keyPath: KeyPath<Wrapped, T>) -> T {
        map { wrapped in
            wrapped[keyPath: keyPath]
        } ?? T.defaultValue
    }

    func mapOrEmpty<T: HasEmptyValue>(keyPath: KeyPath<Wrapped, T>) -> T {
        map { wrapped in
            wrapped[keyPath: keyPath]
        } ?? T.emptyValue
    }
}
