//
// Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation

public extension URL {

    enum Error: Swift.Error {
        case invalidURL(string: String)
    }

    static func throwingInit(string: String) throws -> URL {
        guard let url = URL(string: string) else {
            throw Error.invalidURL(string: string)
        }
        return url
    }
}
