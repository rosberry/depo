//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public struct AnyArgument<Root> {

    let value: (Root) -> [String]

    init<T>(optionalKeyPath: KeyPath<Root, T?>, _ key: String, _ map: @escaping (T) -> String = { "\($0)" }) {
        value = { root in
            root[keyPath: optionalKeyPath].map { value in
                (key + map(value)).words
            } ?? []
        }
    }

    init<T>(_ keyPath: KeyPath<Root, T>, _ key: String, _ map: @escaping (T) -> String = { "\($0)" }) {
        value = { root -> [String] in
            (key + map(root[keyPath: keyPath])).words
        }
    }
}
