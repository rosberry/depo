//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

struct Version: Codable {

    private enum CodingKeys: String, CodingKey {
        case value
        case _isOptimistic = "isOptimistic"
    }

    let value: String
    var isOptimistic: Bool {
        _isOptimistic ?? false
    }

    private let _isOptimistic: Bool?
}
