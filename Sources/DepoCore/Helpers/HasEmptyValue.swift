//
// Copyright © 2021 Rosberry. All rights reserved.
//

public protocol HasEmptyValue {
    static var emptyValue: Self { get }
}

extension Array: HasEmptyValue {
    public static var emptyValue: [Element] {
        []
    }
}

extension String: HasEmptyValue {
    public static var emptyValue: String {
        ""
    }
}
