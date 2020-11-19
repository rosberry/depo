//
// Copyright © 2020 Rosberry. All rights reserved.
//

import struct Foundation.URL

extension URL {
    var absoluteStringWithoutScheme: String {
        let protocolPart = scheme.map { "\($0)://" } ?? ""
        return absoluteString.replacingOccurrences(of: protocolPart, with: "")
    }
}