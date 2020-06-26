//
// Copyright (c) 2020 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

struct Pod: Codable {

    private enum CodingKeys: String, CodingKey {
        case name
        case _isOptimistic = "isOptimistic"
        case version
    }

    let name: String
    var isOptimistic: Bool {
        _isOptimistic ?? false
    }
    let version: Double?

    private let _isOptimistic: Bool?
}
