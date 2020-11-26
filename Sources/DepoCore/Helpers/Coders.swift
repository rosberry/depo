//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public protocol TopLevelDecoder {
    associatedtype Input

    func decode<T: Decodable>(_ type: T.Type, from: Self.Input) throws -> T
}

public protocol TopLevelEncoder {
    associatedtype Output

    func encode<T: Encodable>(_ object: T) throws -> Self.Output
}
