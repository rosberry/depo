//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

struct AnyArgument<Root> {

    let value: (Root) -> [String]

    init<T>(optionalKeyPath: KeyPath<Root, T?>, _ key: String, _ map: @escaping (T) -> String = { "\($0)" }) {
        value = { root in
            root[keyPath: optionalKeyPath].map { value in
                (key + map(value)).split(separator: " ").map { substring in
                    String(substring)
                }
            } ?? []
        }
    }

    init<T>(_ keyPath: KeyPath<Root, T>, _ key: String, _ map: @escaping (T) -> String = { "\($0)" }) {
        value = { root -> [String] in
            (key + map(root[keyPath: keyPath])).split(separator: " ").map { substring in
                String(substring)
            }
        }
    }
}
