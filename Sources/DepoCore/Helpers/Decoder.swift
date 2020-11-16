//
// Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public protocol TopLevelDecoder {
    associatedtype Input

    func decode<T>(_ type: T.Type, from: Self.Input) throws -> T where T: Decodable
}
