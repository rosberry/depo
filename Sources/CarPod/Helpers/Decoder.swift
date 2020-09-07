//
// Copyright © 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

protocol TopLevelDecoder {
    associatedtype Input

    func decode<T>(_ type: T.Type, from: Self.Input) throws -> T where T : Decodable
}
